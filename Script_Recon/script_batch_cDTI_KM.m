

function script_batch_cDTI_KM(struct_diff,UI)

    % Batch script meant for being called from the Batch_Manager. 
    % the script exepct a struct_diff 
    warning off;

    enum=[];
    Dcm=[];

    %%
    %%%%%%%%%%%%%%% Create Enum and Vol %%%%%%%%%%%%%%%%
    [Dcm enum]= AnalyseDataSet_KM(struct_diff.Listing);
    %[Dcm enum]= AnalyseDataSet_forced_KM(listing, [1],[0 350],[1 6],[1 1]);
    enum.dcm_dir=struct_diff.DcmFolder;
    enum.recon_dir=struct_diff.ReconFolder;
    if ~isempty(struct_diff.old_batch_path)
        enum.old_recon=struct_diff.old_batch_path(end);
    else
        enum.old_recon=0;
    end
     enum.nset=1;
    save(fullfile(enum.recon_dir, 'RAW.mat'),'Dcm','enum');
    if UI.gif_mode
        mkdir(fullfile(enum.recon_dir,'Gif'));
        DiffRecon_ToolBox.Gif_KM(Dcm, enum, 'Raw')
    end
    if length(enum.b)>1
        if (enum.dataset.slc(1).b(1).dir(1).nb_avg>enum.dataset.slc(1).b(2).dir(1).nb_avg) % there is more b0 than b-values therefore it's T2 values
            enum.dataset.slc(1).b(1).dir(1).nb_avg=enum.dataset.slc(1).b(2).dir(1).nb_avg;
            DcmB0_T2=Dcm(:,:,1,1,1,enum.dataset.slc(1).b(2).dir(1).nb_avg+1:end);
            Dcm(:,:,1,1,1,enum.dataset.slc(1).b(2).dir(1).nb_avg+1:end)=nan;
        end
    end

    %%
    %%%%%%%%%%%%%%% Unmosaic %%%%%%%%%
    if UI.mosa_mode && enum.mosa>1
        [Dcm, enum]= DiffRecon_ToolBox.Demosa_KM(Dcm, enum);
        save(fullfile(enum.recon_dir, 'Demosa.mat'),'Dcm','enum');
        if UI.gif_mode
            DiffRecon_ToolBox.Gif_KM(Dcm, enum, 'Unmosaic')
        end
    end

    %%
    %%%%%%%%%%%%%%% Registration Before %%%%%%%%%
    if UI.rigid_mode
        [Dcm]= DiffRecon_ToolBox.RigidRegistration_before_KM(Dcm, enum);
        save(fullfile(enum.recon_dir, 'RigidBefore.mat'),'Dcm','enum');
        if UI.gif_mode
            DiffRecon_ToolBox.Gif_KM(Dcm, enum, 'RigidReg_Before')
        end
    end

    if UI.Nrigid_mode
        [Dcm]= DiffRecon_ToolBox.NonRigidRegistration_KM(Dcm, enum);
        save(fullfile(enum.recon_dir, 'NonRigid.mat'),'Dcm','enum');
        if UI.gif_mode
            DiffRecon_ToolBox.Gif_KM(Dcm, enum, 'NonRigidReg')
        end
    end



    %%
    %%%%%%%%%%%%%%% PCA %%%%%%%%%
    if UI.pca_mode
        [Dcm ]= DiffRecon_ToolBox.VPCA_KM(Dcm,enum,80);
        save(fullfile(enum.recon_dir, 'PCA.mat'),'Dcm','enum');
    end

    %%
    %%%%%%%%%%%%%%% tMIP %%%%%%%%%
    if UI.tmip_mode
        [Dcm enum]= DiffRecon_ToolBox.tMIP_KM(Dcm, enum);
        save(fullfile(enum.recon_dir, 'tMIP.mat'),'Dcm','enum');
         if UI.gif_mode
            DiffRecon_ToolBox.Gif_KM(Dcm, enum, 'tMIP')
        end
    end

    %%
    %%%%%%%%%%%%%%%% Average %%%%%%%%%
    if UI.avg_mode   
        [Dcm enum]= DiffRecon_ToolBox.Average_KM(Dcm, enum); 
        save(fullfile(enum.recon_dir, 'Average.mat'),'Dcm','enum');
        if UI.gif_mode
            DiffRecon_ToolBox.Gif_KM(Dcm, enum, 'Average')
        end
    end

    %%
    %%%%%%%%%%%%%%%% Average and reject %%%%%%%%%
    if UI.avg2_mode 
        [Dcm  enum]= DiffRecon_ToolBox.Average_and_Reject_KM(Dcm, enum,3e-3);
        save(fullfile(enum.recon_dir, 'Average_Reject.mat'),'Dcm','enum');
         if UI.gif_mode
            DiffRecon_ToolBox.Gif_KM(Dcm, enum, 'Average_Reject')
        end
    end
    %%
    %%%%%%%%%%%%%%% Registration After %%%%%%%%%
    if UI.rigid_mode
        [Dcm]= DiffRecon_ToolBox.RigidRegistration_KM(Dcm, enum);
        save(fullfile(enum.recon_dir, 'RigidAfter.mat'),'Dcm','enum');
        if UI.gif_mode
            DiffRecon_ToolBox.Gif_KM(Dcm, enum, 'RigidReg_After')
        end
    end

    %%
    %%%%%%%%%%%%%%% Zero filling interpolation %%%%%%%%%
    if UI.inter_mode
       % [Dcm2 enum]= Depolation_KM(Dcm, enum);

       [Dcm enum]= DiffRecon_ToolBox.Interpolation_KM(Dcm, enum);
       %[Dcm enum]=Scaling_KM(Dcm,enum,[200  1.9531]);
        save(fullfile(enum.recon_dir, 'Interpolation.mat'),'Dcm','enum');
         if UI.gif_mode
            DiffRecon_ToolBox.Gif_KM(Dcm, enum, 'Interpolation')
        end
    end 
    %[Dcm enum]= Mean_KM(Dcm, enum);
    %%
    %%%%%%%%%%%%%%% Create Trace %%%%%%%%%
    if UI.trace_mode
        [Trace enum]= DiffRecon_ToolBox.Trace_KM(Dcm, enum,1);
        [Trace_Norm]= DiffRecon_ToolBox.Norm_KM(Trace, enum);  
        save(fullfile(enum.recon_dir, 'Trace.mat'),'Trace','Trace_Norm','enum');  
        if UI.gif_mode
            DiffRecon_ToolBox.Gif_KM(Trace, enum, 'Trace')
        end
    end

    %%
    %%%%%%%%%%%%%%% Calculate ADC %%%%%%%%%
    if UI.ADC_mode   
        [ADC]= DiffRecon_ToolBox.ADC_KM(Trace, enum);
        if enum.datasize.b>2
           ADC(:,:,:,3)=log(Trace(:,:,:,3)./Trace(:,:,:,2)) ./ (enum.b(2)-enum.b(3));
        end
        save(fullfile(enum.recon_dir,'ADC.mat'),'ADC');
    end


    %%
    %%%%%%%%%%%%%%% Create Mask %%%%%%%%%
    if UI.mask_mode
        [Mask]= DiffRecon_ToolBox.Mask_KM(Trace(:,:,:,2),60,60000);
        Mask(Mask>0)=1;
        %Dcm=Apply_Mask_KM(Dcm,Mask);
        save(fullfile(enum.recon_dir, 'Mask.mat'),'Mask','Dcm');  
    end
    %%
    %%%%%%%%%%%%%%% Create ROI %%%%%%%%%
    if UI.roi_mode    
             if  UI.loadROI_current
                  load(fullfile(enum.recon_dir, 'ROI.mat'));
             elseif UI.loadROI_old & enum.old_recon
                  load(fullfile(enum.old_recon, 'ROI.mat'));       
             else
                  [P_Endo,P_Epi,LV_Mask,Mask_Depth]= DiffRecon_ToolBox.ROI_KM(Trace(:,:,:,2));
                  [Mask_AHA] = DiffRecon_ToolBox.ROI2AHA_KM (Dcm, P_Endo, P_Epi);
             end
             save(fullfile(enum.recon_dir, 'ROI.mat'),'P_Endo','P_Epi','LV_Mask','Mask_AHA','Mask_Depth');    
    end
    %%
    %%%%%%%%%%%%%%% Calculate Tensor %%%%%%%%%
    if UI.DTI_mode
        [Tensor,EigValue,EigVector,MD,FA,Trace_DTI] = DiffRecon_ToolBox.Calc_Tensor_KM(Dcm, enum);
        save(fullfile(enum.recon_dir, 'DTI.mat'),'Tensor','EigValue','EigVector','MD','FA','Trace_DTI');  

       %%%%%%%%%%%%%% Extract HA %%%%%%%%%%%%%
        if UI.roi_mode

            load(fullfile(enum.recon_dir,'DTI.mat'))
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
            save(fullfile(enum.recon_dir, 'HA.mat'),'EigVect1','EigVect2','EigVect3','Elevation','HA','TRA','HA_filter','HA_filter2','E2A');

            % DTI2VTK_KM(EigVector,LV_Mask, enum,1,[],'test',[1 1 1]); % Uncomment to export fiber to
            % VTK
        end
    end
    warning on;
end
%%
% if UI.ADC_mode  && UI.trace_mode 
%     [Folder]= Recreate_Dicom_Maps_KM(ADC*1e6.*Mask,enum,[],'ADCMap',1015);
% 	Recreate_Dicom_Maps_KM(Trace*1e1.*Mask,enum,Folder,'TraceMap',1016);
% end


%%
