%WRITEOUTPUT_FOLDCHANGES Writes output tables for the PRINCE FoldChanges
%   module

fn = [datadir '/Fold_change_' user.comparisonpairs{1} '_vs_' user.comparisonpairs{2} '.csv'];
fid = fopen(fn,'w');
fprintf (fid,'%s,%s,%s,%s,%s\n','Protein ID','Replicate','Fraction (Gauss center)','log2 Fold change','log2 Fold change (normalized)');
for ii = 1:length(Finalised_Master_Gaussian_list.Protein_name)
  prot = Finalised_Master_Gaussian_list.Protein_name{ii,1};
  if isempty(prot); continue; end
  I = find(ismember(Combined_Gaussians.Protein_name,prot));
  reps = Combined_Gaussians.Replicate(I);
  centers = Combined_Gaussians.Center(I);
  foldChange = Combined_Gaussians.log2_of_gaussians(I);
  foldChange_norm = Combined_Gaussians.log2_normalised_gaussians(I);
  %reps = Finalised_Master_Gaussian_list.Replicate(ii,:);
  %centers = Finalised_Master_Gaussian_list.Center(ii,:);
  %foldChange = Finalised_Master_Gaussian_list.foldChange(ii,:);
  %foldChange_norm = Finalised_Master_Gaussian_list.foldChange_normalized(ii,:);
  for jj = 1:length(I)
    fprintf(fid,'%s,%d,%6.4f,%6.4f,%6.4f\n',...
      prot,reps(jj), centers(jj), foldChange(jj), foldChange_norm(jj));
  end
end



% % #output
% %Write out comparsion of gaussian in biological replicate
% s = [datadir '/Final_2foldchange_list_between_' user.comparisonpairs{1} 'and' user.comparisonpairs{2} '.csv'];
% fid_combined_gaus_with_changes_output= fopen(s,'wt'); % create the output file with the header infromation
% fprintf (fid_combined_gaus_with_changes_output,'%s,%s,%s,%s,%s,%s,%s,%s,%s,%s\n',... %header for OutputGaus output
%   'Protein name', 'Replicate', 'Height', 'Center', 'Width', 'adjrsquare','Observed in channel','Changes Observed',...
%   'Fold Change (based on raw data)','Normalise Fold Change (based on raw data)'); %Write Header
% for writeout_counter1= 1:number_of_proteins
%   fprintf(fid_combined_gaus_with_changes_output,'%s,%d,%6.3f,%6.3f,%6.3f,%6.3f,%6.3f,%s,%s,%6.4f,%6.4f,\n',...
%     Combined_Gaussians.Protein_name{writeout_counter1},...
%     Combined_Gaussians.Replicate(writeout_counter1),...
%     Combined_Gaussians.Height(writeout_counter1),...
%     Combined_Gaussians.Center(writeout_counter1),...
%     Combined_Gaussians.Width(writeout_counter1),...
%     Combined_Gaussians.adjrsquare(writeout_counter1),...
%     Combined_Gaussians.Channels{writeout_counter1},...
%     Combined_Gaussians.Observed_change{writeout_counter1},...
%     Combined_Gaussians.log2_of_gaussians(writeout_counter1),...
%     Combined_Gaussians.log2_normalised_gaussians(writeout_counter1));
% end
% fclose(fid_combined_gaus_with_changes_output);
% 
% 
% % #output
% %Write out trend observed in gaussian grouped by proteins and replicate
% fid_summed_area= fopen([datadir '/Final_2foldchange_trends_' user.comparisonpairs{1} 'and' user.comparisonpairs{2} '.csv'],'wt'); % create the output file with the header infromation
% fprintf (fid_summed_area,'%s,%s,%s,%s,%s\n',... %header for OutputGaus output
%   'Protein name', 'Replicate', 'Number of gaussians observed','Observed change',' Were changes consistent across all guassians'); %Write Header
% for writeout_counter1= 1:NuniqueGauss
%   fprintf(fid_summed_area,'%s,%d,%6.3f,%s,%s,\n',...
%     GaussSummary(1).Protein_name{writeout_counter1},...
%     GaussSummary(1).Replicate(writeout_counter1,1),...
%     Ngaussperrep_prot(writeout_counter1),...
%     trendString{writeout_counter1,1},...
%     trendString{writeout_counter1,2});
% end
% fclose(fid_summed_area);
% 
% 
% % #output
% %Write table of is gaussian were fitted in the HvsL and/or MvsL
% s = [datadir '/Gaussian_list.csv'];
% fid_combined_gaus_output= fopen(s,'wt'); % create the output file with the header infromation
% fprintf (fid_combined_gaus_output,'%s,%s,%s,%s,%s,%s,%s,%s\n',... %header for OutputGaus output
%   'Protein name','Replicate','Complex Size', 'Height', 'Center', 'Width', 'adjrsquare','Observed in channel'); %Write Header
% for writeout_counter1= 1:number_of_proteins
%   fprintf(fid_combined_gaus_output,'%s,%d,%6.3f,%6.3f,%6.3f,%6.3f,%6.3f,%s,\n',...%6.3f,%6.3f,%6.3f,%6.3f,%6.3f,%6.3f,\n',...
%     Combined_Gaussians.Protein_name{writeout_counter1},...
%     Combined_Gaussians.Replicate(writeout_counter1),...
%     Combined_Gaussians.Complex_size(writeout_counter1),...
%     Combined_Gaussians.Height(writeout_counter1),...
%     Combined_Gaussians.Center(writeout_counter1),...
%     Combined_Gaussians.Width(writeout_counter1),...
%     Combined_Gaussians.adjrsquare(writeout_counter1),...
%     Combined_Gaussians.Channels{writeout_counter1});
% end
% fclose(fid_combined_gaus_output);
% 
% 
% fid_Summary_gaussian= fopen([datadir '/Summary_gaussians_detected_between_replicates.csv'],'wt'); % create the summary file of the interaction output
% fprintf (fid_Summary_gaussian,'%s,','Total gaussians');
% for ci = 1:Nchannels
%   fprintf(fid_Summary_gaussian,'%s,',['Gaussians within ' Experimental_channels{ci} ' channel']);
% end
% fprintf(fid_Summary_gaussian,'%s,%s,%s,%s,%s,\n',...
%   'Shared Gaussians','Number of Gaussians that increase', 'Number of Gaussians that decrease',....
%   'Number of Gaussians that do not change','Number of Unquantified');
% fprintf(fid_Summary_gaussian,'%6.4f,',number_of_proteins);
% for ci = 1:Nchannels
%   fprintf(fid_Summary_gaussian,'%6.4f,',Unique_gaussians_in_eachchannel(ci));
% end
% fprintf(fid_Summary_gaussian,'%6.4f,%6.4f,%6.4f,%6.4f,%6.4f,\n',...
%   shared_gaussian_counter, sum(Iinc), sum(Idec), sum(~Idec & ~Iinc), sum(Ibad));
% 
% 
% fid_summed_area1= fopen([datadir '/Summary_gaussian_trend_analysis_protein_replicate.csv'],'wt'); % create the output file with the header infromation
% fprintf (fid_summed_area1,'%s,%s,%s,%s,%s,%s,%s\n',... %header for OutputGaus output
%   'Number of Protein observed across replicates', 'No change- consistent across gaussians', 'Increase- consistent across gaussians',...
%   'Decrease- consistent across gaussians','Increase- inconsistent across gaussians', 'Decrease- inconsistent across gaussians',...
%   'Increase and Decrease observed in Gaussians'); %Write Header
% fprintf (fid_summed_area1,'%6.4f,%6.4f,%6.4f,%6.4f,%6.4f,%6.4f,%6.4f\n',...
%   NuniqueGauss,...
%   No_change_consistent_across_gaus, Increase_consistent_across_gaus,...
%   Decrease_consistent_across_gaus, Increase_inconsistent_across_gaus,...
%   Decrease_inconsistent_across_gaus, Increase_and_decrease_across_gaus);
% fclose(fid_summed_area1);


