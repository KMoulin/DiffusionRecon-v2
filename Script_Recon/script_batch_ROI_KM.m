

function script_batch_ROI_KM(struct_diff)

    % Batch script meant for being called from the Batch_Manager. 
    % the script exepct a struct_diff 
    warning off;


     % We do the ROI only if the trace is calculated
    if isfile(fullfile(struct_diff.ReconFolder, 'Trace.mat'))
        load(fullfile(struct_diff.ReconFolder, 'Trace.mat'))
        [P_Endo,P_Epi,LV_Mask,Mask_Depth]= DiffRecon_ToolBox.ROI_KM(Trace(:,:,:,2));
        [Mask_AHA] = DiffRecon_ToolBox.ROI2AHA_KM (Trace(:,:,:,2), P_Endo, LV_Mask);
        save([enum.recon_dir '/ROI.mat'],'P_Endo','P_Epi','LV_Mask','Mask_AHA','Mask_Depth');    
  
        %[P_Endo,P_Epi,LV_Mask,Mask_Depth]= ROI_NNUNET_KM(Trace(:,:,:,2),enum);
        %save([enum.recon_dir '/ROInet.mat'],'P_Endo','P_Epi','LV_Mask','Mask_Depth'); 

        % We do the HA/E2A calculation in case we have a tensor already
        % reconstruced
        if isfile([struct_diff.ReconFolder '/DTI.mat'])
            load([struct_diff.ReconFolder '/DTI.mat'])
            EigVect1=[];
            EigVect2=[];
            EigVect3=[];
            Elevation=[];
            EigVect1(:,:,1:size(EigVector,3),:)=squeeze(EigVector(:,:,:,1,:,1));
            EigVect2(:,:,1:size(EigVector,3),:)=squeeze(EigVector(:,:,:,1,:,2));
            EigVect3(:,:,1:size(EigVector,3),:)=squeeze(EigVector(:,:,:,1,:,3));
            Elevation(:,:,1:size(EigVector,3),:)=squeeze(EigVector(:,:,:,1,3,1));



            %[HA TRA]= HA_KM( EigVect1, Dcm, P_Epi, P_Endo );
            [HA TRA E2A ]= DiffRecon_ToolBox.HA_E2A_KM(EigVect1, EigVect2, LV_Mask, P_Epi, P_Endo);
            %[HA_filter]= HA_Filter_KM(HA,LV_Mask ,Mask_Depth,0);n

            [HA_filter]= DiffRecon_ToolBox.HA_Filter_KM(HA,LV_Mask ,Mask_Depth,0);
            [HA_filter2]= DiffRecon_ToolBox.HA_Filter_KM(HA_filter,LV_Mask ,Mask_Depth,0);
            save([enum.recon_dir '/HA.mat'],'EigVect1','EigVect2','EigVect3','Elevation','HA','TRA','HA_filter','HA_filter2','E2A');

        end
    else
        
        disp('Trace reconstruction missing for ROI')
    
    end
    
    
  

end

