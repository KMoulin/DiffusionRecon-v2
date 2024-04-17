

function script_batch3_KM(struct_diff)

    % Batch script meant for being called from the Batch_Manager. 
    % the script exepct a struct_diff 
    warning off;


     % We do the ROI only if the trace is calculated
    if isfile([struct_diff.ReconFolder '/Trace.mat'])
        load([struct_diff.ReconFolder '/Trace.mat']);
        if(isfile([struct_diff.ReconFolder '/ROInet.mat']))
             load([struct_diff.ReconFolder  '/ROInet.mat']); 
             tmpIn=cat(2,Trace(:,:,:,2),LV_Mask*200+Trace(:,:,:,2));
             [Mask_AHA] = ROI2AHA_KM (tmpIn, P_Endo, P_Epi,Trace(:,:,:,2));
             save([enum.recon_dir '/ROInet.mat'],'P_Endo','P_Epi','LV_Mask','Mask_Depth','Mask_AHA'); 
        elseif (isfile([struct_diff.ReconFolder '/ROI.mat']))
             load([struct_diff.ReconFolder  '/ROI.mat']); 
             tmpIn=cat(2,Trace(:,:,:,2),LV_Mask*200+Trace(:,:,:,2));
             [Mask_AHA] = ROI2AHA_KM (tmpIn, P_Endo, P_Epi,Trace(:,:,:,2));
             save([enum.recon_dir '/ROI.mat'],'P_Endo','P_Epi','LV_Mask','Mask_Depth','Mask_AHA'); 
        else
             return;
        end
        % [P_Endo,P_Epi,LV_Mask,Mask_Depth]= ROI_KM(Trace(:,:,:,2));
       
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
            [HA2 TRA2 E2A ]= HA_E2A_KM(EigVect1, EigVect2, LV_Mask, P_Epi, P_Endo);
            %[HA_filter]= HA_Filter_KM(HA,LV_Mask ,Mask_Depth,0);n

            [HA_filter2]= HA_Filter_KM(HA2,LV_Mask ,Mask_Depth,0);
            [HA_filter4]= HA_Filter_KM(HA_filter2,LV_Mask ,Mask_Depth,0);
            save([enum.recon_dir '/HA2.mat'],'EigVect1','EigVect2','EigVect3','Elevation','HA2','TRA2','HA_filter2','HA_filter4','E2A');

        end
    else
        
        disp('Trace reconstruction missing for ROI')
    
    end
    
    
  

end

