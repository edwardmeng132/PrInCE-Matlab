


%% 0. Initialize
tic
fprintf('\n    0. Initialize')

minrep = user.minrep; % minimum number of replicates an interaction has to be in

% Define folders, i.e. define where everything lives.
datadir = [user.maindir 'Data/']; % where data files live
figdir = [user.maindir 'Figures/Enrichment/']; % where figures live
% Make folders if necessary
if ~exist(datadir, 'dir'); mkdir(datadir); end
if ~exist([datadir '/Enrichment/'], 'dir'); mkdir([datadir '/Enrichment/']); end
if ~exist(figdir, 'dir'); mkdir(figdir); end


InteractionIn = cell(length(user.desiredPrecision),1);
countPrec = 0;
for ii = 1:length(user.desiredPrecision)
  s1 = ['Final_Interactions_list_' num2str(user.desiredPrecision(ii)*100) '_precision.csv'];
  s = [user.maindir 'Data/ROC/CombinedResults/' s1];
  
  if ~exist(s,'file')
    fprintf('\n    Error: Enrichment: Following interaction file not found:')
    fprintf('\n        %s\n',s1)
  else
    countPrec = countPrec+1;
    InteractionIn{countPrec} = s;
  end
end
if countPrec == 0
  fprintf('\n    Error: Enrichment: No interaction files found!')
end
InteractionIn = InteractionIn(1:countPrec);


tt = toc;
fprintf('  ...  %.2f seconds\n',tt)




%% 1. Read input data
tic
fprintf('    1. Read input data')

% Load interactions detected by ROC_PCPSILAC
interactionPairs = cell(countPrec,1);
for ii = 1:countPrec
  tmp = importdata(InteractionIn{ii});
  
  % remove header from textdata if necessary
  if size(tmp.textdata,1)==size(tmp.data,1)+1
    tmp.textdata = tmp.textdata(2:end,:);
  elseif size(tmp.textdata,1)==size(tmp.data,1)
  else
    disp('Error: Enrichment: Mismatch between imported numerical and text data sizes')
  end
  
  % only need the Protein-A, Protein-B, and number-of-replicates columns
  % Hard code these to columns 2 and 3
  interactionPairs{ii} = tmp.textdata(:,[2:3 6]);
end

% List of N unique protein names
uniqueProteins = [];
for ii = 1:countPrec
  tmp = interactionPairs{ii}(:,1:2);
  uniqueProteins = unique([uniqueProteins; tmp(:)]);
end
Nprot = length(uniqueProteins);

% Load CORUM interactions
corumPairs_tmp = importdata(user.corumfile);
corumPairs_tmp = unique(corumPairs_tmp);

% Check that corumPairs is an mx1 cell
if ~iscell(corumPairs_tmp) || size(corumPairs_tmp,2)~=1
  error('Error: Enrichment: Incorrectly formatted CORUM file')
end

% split corumPairs into a mx2 cell
% this method is surprisingly faster than cellfun(@strsplit)
corumPairs = cell(length(corumPairs_tmp),2);
for ii = 1:length(corumPairs_tmp)
  fn = corumPairs_tmp{ii};
  for jj = 1:length(fn)
    if fn(jj) == ','
      corumPairs{ii,1} = fn(1:jj-1);
      corumPairs{ii,2} = fn(jj+1:end);
    end
  end
end
clear corumPairs_tmp

% Turn interactionPairs,corumPairs into indices of uniqueProteins
% (numerical pairs are easier to work with!)
% In interaction index pairs, also include how many replicates it was seen in.
interactionPairs2 = cell(countPrec,1);
for kk = 1:countPrec
  interactionPairs2{kk} = nan(size(interactionPairs{kk},1),3);
end
corumPairs2 = nan(size(corumPairs));
for ii = 1:length(uniqueProteins)
  % corumPairs
  [Ic1,Ic2] = find(ismember(corumPairs,uniqueProteins{ii}));
  for jj = 1:length(Ic1)
    corumPairs2(Ic1(jj),Ic2(jj)) = ii;
  end
  
  % interactionPairs
  for kk = 1:countPrec
    [I1,I2] = find(ismember(interactionPairs{kk},uniqueProteins{ii}));
    for jj = 1:length(I1)
      interactionPairs2{kk}(I1(jj),I2(jj)) = ii;
      % include the number of replicates
      tmp = interactionPairs{kk}{I1(jj),3};
      nrep = length(unique(tmp(isstrprop(tmp,'digit'))));
      interactionPairs2{kk}(I1(jj),3) = nrep;
    end
  end
end

% corumPairs has both A-B and B-A interactions.
% Remove the redundant entries.
corumPairs2 = sort(corumPairs2,2);
[corumPairs2,I1,I2] = unique(corumPairs2,'rows');
% Use the same indices to remove redundant entries from the string list.
corumPairs = corumPairs(I1,:);



tt = toc;
fprintf('  ...  %.2f seconds\n',tt)





% %% 2. Build complexes
% 
% %
% 
% %
% % Inputs: N1x2 interaction list, N2x2 CORUM list, list of N unique protein names, Nx1 binary
% % Outputs: Complex(i).Members, Complex(i).Connections
% tic
% fprintf('    2. Build complexes')
% 
% 
% clear ComplexList
% for ii = 1:countPrec
%   % Make NxN interaction matrix
%   intMatrix = zeros(Nprot,Nprot);
%   % add nrep
%   for jj = 1:size(interactionPairs2{ii},1)
%     x = interactionPairs2{ii}(jj,1:2);
%     nrep = interactionPairs2{ii}(jj,3);
%     intMatrix(x(1),x(2)) = intMatrix(x(1),x(2)) + nrep;
%     intMatrix(x(2),x(1)) = intMatrix(x(2),x(1)) + nrep;
%   end
%   
%   % add 100*inCorum
%   I = find(~isnan(corumPairs2(:,1)) & ~isnan(corumPairs2(:,2)));
%   for jj = 1:length(I)
%     x = corumPairs2(I(jj),1:2);
%     intMatrix(x(1),x(2)) = intMatrix(x(1),x(2)) + 100;
%     intMatrix(x(2),x(1)) = intMatrix(x(2),x(1)) + 100;
%   end
%   
%   % Reduce intMatrix to just upper-triangular
%   intMatrix = triu(intMatrix);
%   
%   % Binary vector
%   % Used to keep track of which proteins have already been assigned to a complex
%   bv = zeros(Nprot,1);
% 
%   % Start finding complexes
%   countcmplx = 0;
%   for jj = 1:Nprot
%     % check if this protein is already in a complex
%     if bv(jj)==1
%       continue;
%     end
%     
%     I = find(intMatrix(jj,:)>=minrep | intMatrix(:,jj)'>=minrep);
%     if ~isempty(I)
%       % initialize this complex
%       countcmplx = countcmplx+1;
%       bv(jj) = 1;
%       membs = [jj I];
%       
%       % BOOM! Another option is to IGNORE open_branches. Just keep exploring ALL branches, adding
%       % interactions to the list, and pruning with unique. When the list stops growing, you've
%       % stopped finding new interactions, and the complex is complete. Ignore the binary vector!
%       
%       % start exploring connections
%       open_branches = membs(bv(membs)==0);
%       %delta_membs = 1;
%       while ~isempty(open_branches)
%       %while delta_membs>0
%         %nmembs = length(membs);
%         for kk = 1:length(open_branches)
%           I2 = find(intMatrix(open_branches(kk),:)>=minrep | intMatrix(:,open_branches(kk))'>=minrep);
%           membs = [membs I2];
%         end
%         membs = unique(membs);
%         open_branches = membs(bv(membs)==0);
%         bv(open_branches) = 1;
%         %delta_membs = length(membs) - nmembs;
%         %[length(open_branches) delta_membs]
%         length(open_branches)
%       end
%       
%       ComplexList(ii).Members{countcmplx} = membs;
%       ComplexList(ii).Connections{countcmplx} = intMatrix(membs,membs);
%     end
%   end
%   
%   % Check that all proteins are in a complex
%   intcount = 0;
%   for jj = 1:countcmplx
%     intcount = intcount+sum(ComplexList(ii).Connections{jj}(:)>=minrep);
%   end
%   if intcount~=sum(intMatrix(:)>=minrep)
%     s1 = ['Number of proteins interacting: ' num2str(sum(intMatrix(:)>1))];
%     s2 = ['Number of proteins in a complex: ' num2str(intcount)];
%     disp(s1)
%     disp(s2)
%   end
% end
% 
% tt = toc;
% fprintf('  ...  %.2f seconds\n',tt)
% 
% 
% 
% %% 3. Build complexes
% % MCL
% % Input: normalized interaction matrix, mcl parameters
% 
% clear ComplexList
% for ii = 1:countPrec
%   % Make NxN interaction matrix
%   intMatrix = zeros(Nprot,Nprot);
%   % add nrep
%   for jj = 1:size(interactionPairs2{ii},1)
%     x = interactionPairs2{ii}(jj,1:2);
%     nrep = interactionPairs2{ii}(jj,3);
%     intMatrix(x(1),x(2)) = intMatrix(x(1),x(2)) + nrep;
%     intMatrix(x(2),x(1)) = intMatrix(x(2),x(1)) + nrep;
%   end
%   
%   % add 100*inCorum
%   I = find(~isnan(corumPairs2(:,1)) & ~isnan(corumPairs2(:,2)));
%   for jj = 1:length(I)
%     x = corumPairs2(I(jj),1:2);
%     intMatrix(x(1),x(2)) = intMatrix(x(1),x(2)) + 100;
%     intMatrix(x(2),x(1)) = intMatrix(x(2),x(1)) + 100;
%   end
%   
%   % Reduce intMatrix to binary 
%   intMatrix = single(intMatrix>=minrep);
%   
%   % Normalize intMatrix
%   %nint = sum(intMatrix)+1;
%   %intMatrix2 = intMatrix ./ repmat(nint,Nprot,1);
%   total_unique_proteins_interacting_with = sum(intMatrix,2);
%   intMatrix2 = zeros(Nprot,Nprot);
%   for jj = 1:Nprot
%     if total_unique_proteins_interacting_with(jj)>0
%       intMatrix2(:,jj)=intMatrix(jj,:)./total_unique_proteins_interacting_with(jj);
%     end
%   end
%   
%   % MCL varibales
%   energy = 1;
%   delta_energy = 1;
%   emax = 0.001;
%   p = 2;
%   minval = 0.000001;
%   
%   %Repeat till the variation is less then 10% OR 10 interations have been
%   %evaluated, Note the limit on interations is due convergence always being
%   %outcome from MCL
%   iteration = 0;
%   %while (energy > emax*1.10 || energy < emax*0.90) || iteration== 10
%   while delta_energy>0.1 && iteration<10
%     iteration=iteration+1;
%     
%     %Set emax
%     emax = energy;
%     
%     m2 = intMatrix2 .^ p;       % inflation
%     I = m2 < minval;            % pruning
%     m2(I) = 0;
%     dinv = diag(1./sum(m2));    % normalisation
%     m2 = m2 * dinv;
%     m2(isnan(m2))=0;            % Remove NaN with zeros
%     
%     % calculate residual energy
%     maxs = max(m2);
%     sqsums = sum(m2 .^ 2);
%     energy = max(maxs - sqsums);
%     delta_energy = abs((energy - emax) ./ emax);
%     
%     %write out values
%     s = ['iter=' num2str(iteration) ', prev_energy=' num2str(emax) ', energy=' num2str(energy) ', Delta_energy=' num2str(delta_energy)];
%     disp(s)
%         
%     %set m2 to mTemp
%     intMatrix2 = m2;
%   end
%   
%   n1 = sum(intMatrix(:)>0);
%   n2 = sum(intMatrix2(:)>0);
%   nremoved = n1 - n2;
%   fprintf('\nStarted with %d interactions, ended with %d, i.e. removed %d\n\n', n1, n2, nremoved)
%   
% end



%% 2. Build complexes
%       i) Make "coded" interaction matrix.
%      ii) Prune interactions with MCL.
%     iii) Build complexes with my algorithm.
%
% One trick used here: interaction matrix values equal number of replicates + 100*inCorum. This will
% give a values like 102 (in 2 replicates and Corum) and 3 (in 3 replicates, not corum).
% This is designed to use a single interaction matrix, since this can be very large for >3000
% proteins.
% 
% Note that interactions with a value less than minrep are ignored.
tic
fprintf('    2. Build complexes')

% Pre-allocate
Ninit = nan(countPrec,1);
Nfinal = nan(countPrec,1);
Ncomplex = nan(countPrec,1);

clear ComplexList
for ii = 1:countPrec
  % i) Make "coded" interaction matrix
  intMatrix = zeros(Nprot,Nprot);
  for jj = 1:size(interactionPairs2{ii},1)
    x = interactionPairs2{ii}(jj,1:2);
    nrep = interactionPairs2{ii}(jj,3);
    intMatrix(x(1),x(2)) = intMatrix(x(1),x(2)) + nrep;  % add nrep
    intMatrix(x(2),x(1)) = intMatrix(x(2),x(1)) + nrep;
  end  
  I = find(~isnan(corumPairs2(:,1)) & ~isnan(corumPairs2(:,2)));
  for jj = 1:length(I)
    x = corumPairs2(I(jj),1:2);
    intMatrix(x(1),x(2)) = intMatrix(x(1),x(2)) + 100;  % add 100*inCorum
    intMatrix(x(2),x(1)) = intMatrix(x(2),x(1)) + 100;
  end
  
  
  % ii) Prune interaciton matrix with MCL.
  % MCL varibales
  mclparams.minrep = minrep;
  mclparams.p = 2;
  %mclparams.minval = 0.000001;
  mclparams.minval = 0.005;
  Ninit(ii) = sum(intMatrix(:)>=minrep);
  intMatrix = mclpcp(intMatrix,mclparams);
  Nfinal(ii) = sum(intMatrix(:)>=minrep);
  
  
  % iii) Build complexes with my algorithm.
  [ComplexList(ii).Members, ComplexList(ii).Connections] = buildcomplex(intMatrix);
  Ncomplex(ii) = length(ComplexList(ii).Members);
end

tt = toc;
fprintf('  ...  %.2f seconds\n',tt)



%% 3. Attach disease labels
% Find each protein in the fasta file, and obtain the gene name.
% Find that gene name in the omim file, and attach the disease label.

tic
fprintf('    4. Run enrichment analysis')

% load whole fastafile to variable
fastatext = fileread(user.fastafile);
Inewline = find(fastatext == 13); % find all newline characters in the fastafile
Ign = strfind(fastatext, 'GN='); % find all Gene Name declarations in the fastafile

% load whole omimfile to variable
omimtext = fileread(user.omimfile);
inewline = find(omimtext == 13 | omimtext == 10); % find all newline characters in the fastafile

% DLsummvect will will summarize label attaching
% 1 = Disease Label attached
% 2 = protein not found in fasta file
% 3 = protein in fasta, but no gene name
% 4 = protin and gene name fasta, but gene name not in omim
DLsummvect = nan(Nprot,1);

geneName = cell(size(uniqueProteins));
diseaseLabel = zeros(size(uniqueProteins,1),10); 
for ii = 1:Nprot
  ii
  
  protName = uniqueProteins{ii};
  s = ['|' protName '|'];
  
  % look for protName in the fasta file
  Iprot = strfind(fastatext, s);
  
  % Search the fasta file for this protein's gene name
  % find the Ign between Iprot and Inewline
  if isempty(Iprot)
    DLsummvect(ii) = 2;
    continue;
  end
  Inextline = Inewline(find(Inewline>Iprot,1,'first'));
  Istart = Ign(Ign>Iprot & Ign<Inextline); % Gene Name occurring immediately after protName
  if isempty(Istart)
    DLsummvect(ii) = 3;
    continue;
  end
  Iend1 = strfind(fastatext(Istart:Istart+20),' '); % look for white space
  Iend2 = find(fastatext(Istart:Istart+20) == 13); % look for newline
  Iend = min([Iend1 Iend2]) + Istart -2;
  geneName{ii} = fastatext(Istart+3:Iend);
  
  % Search the omim file for this gene's disease label(s)
  s2 = [char(9) geneName{ii} char(9)];
  igenename = strfind(omimtext,s2);
  if isempty(igenename)
    DLsummvect(ii) = 4;
    continue;
  end
  for jj = 1:length(igenename)
    iprevline = inewline(find(inewline<igenename(jj),1,'last'));
    iend = find(omimtext(iprevline:igenename(jj))==9) + iprevline;
    iend = iend(1);
    diseaseLabel(ii,jj) = str2double(omimtext(iprevline+1:iend-2));
  end
  
  DLsummvect(ii) = 1;
end
uniqueDiseases = unique(diseaseLabel(:));
uniqueDiseases(uniqueDiseases==0) = [];
Ndis = length(uniqueDiseases);

% Make truncated disease labels
DL = cell(5,1);
for ii = 1:5
  DL{ii} = zeros(Nprot,1);
  for jj = 1:Nprot
    if diseaseLabel(jj,1)==0
      continue;
    end
    tmp = num2str(diseaseLabel(jj,1));
    DL{ii}(jj) = str2double(tmp(1:ii));
  end
  UD{ii} = unique(DL{ii});
  UD{ii}(UD{ii}==0) = [];
  ND(ii) = length(UD{ii});
end
DL{6} = diseaseLabel;
UD{6} = uniqueDiseases;
ND(6) = Ndis;

tt = toc;
fprintf('  ...  %.2f seconds\n',tt)



%% 4. Run enrichment analysis
%       i) Look at every Complex-Disease pair.
%      ii) For each pair, make a contingency table T.
%     iii) Calculate p(ii) = fisherexact(T).
%      iv) Run B-H correction on all p.

tic
fprintf('    4. Run enrichment analysis')

cc = 2;
dd = 3;

% Make list of Disease labels for each protein
% diseaseLabels = zeros(Nprot,5);
% for ii = 1:Nprot
%   tmp = round(rand(1,5)*100);
%   tmp = tmp(tmp<=50);
%   diseaseLabels(ii,1:length(tmp)) = tmp;
% end
% uniqueDiseases = unique(diseaseLabels(:));
% Ndis = length(uniqueDiseases);
% 
% % FAKE!!!
% % "Enrich" a small number of clusters
% Icomplex = randsample(1:Ncomplex(cc),1);
% for ii = Icomplex
%   Idisease = randsample(uniqueDiseases,1);
%   for jj = ComplexList(cc).Members{ii}
%     diseaseLabels(jj,:) = Idisease;
%   end
% end
% FAKE!!!

% Fisher exact test
p_enrich = nan(Ncomplex(cc),ND(dd));
for ii = 1:Ncomplex(cc)
  I = ComplexList(cc).Members{ii};  % index of proteins in this complex
  I0 = ~ismember(1:Nprot,ComplexList(cc).Members{ii});  % index of proteins NOT in this cluster
  
  for jj = 1:ND(dd)
    dl = UD{dd}(jj); % current disease label
    dlcomp = DL{dd}(I,:); % all disease labels for this complex
    dlcomp0 = DL{dd}(I0,:); % all disease labels for proteins NOT in this complex
    
    % Make contingency table
    a = sum(dlcomp(:) == dl & dlcomp(:)~=0);  % in cluster       AND disease label
    b = sum(dlcomp(:) ~= dl & dlcomp(:)~=0);  % in cluster       AND NOT disease label
    c = sum(dlcomp0(:)== dl & dlcomp0(:)~=0); % NOT in cluster   AND disease label
    d = sum(dlcomp0(:)~= dl & dlcomp0(:)~=0); % NOT in cluster   AND NOT disease label
    T = [a b; c d];
    [~,p_enrich(ii,jj)] = fishertest(T);
  end
end

% Benjamini-Hochberg
p_asc = sort(p_enrich(:),'ascend');
if size(p_asc,1)>size(p_asc,2)
  p_asc = p_asc';
end
m = length(p_asc);
I = find( (1:m)/m*user.fdr - p_asc >= 0, 1, 'last');
pcutoff = p_asc(I);

% figure,hold on
% plot(p_asc,'k')
% plot((1:m)/m*user.fdr,'r')
% axis([0 25 0 .005])

figure
imagesc(p_enrich<=pcutoff)

tt = toc;
fprintf('  ...  %.2f seconds\n',tt)




