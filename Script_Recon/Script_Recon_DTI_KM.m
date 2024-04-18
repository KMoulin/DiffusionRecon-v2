
clear all
close all
warning off;




%%%%%%%%%%%%%%% UI Management %%%%%%%%%%%%%%%%%%%%%%
UI=UIDiffRecon_KM(true);
disp('Select Folder');
dcm_dir = uigetdir;
cd(dcm_dir);
mkdir(fullfile(dcm_dir ,'Maps'))

listing = dir(dcm_dir);


enum=[];
Dcm=[];

%%
%%%%%%%%%%%%%%% Create Enum and Vol %%%%%%%%%%%%%%%%
[Dcm enum]= AnalyseDataSet_KM(listing);
%[Dcm enum]= AnalyseDataSet_forced_KM(listing, [5],[0 350],[1 6],[5 5]);
enum.dcm_dir=dcm_dir;
enum.recon_dir=fullfile(dcm_dir, 'Maps');
enum.nset=1;
save(fullfile(enum.recon_dir ,'RAW.mat'),'Dcm','enum');
if UI.gif_mode
    mkdir(fullfile(enum.recon_dir,'Gif'));
    DiffRecon_ToolBox.Gif_KM(Dcm, enum, 'Raw')
end

if (enum.dataset.slc(1).b(1).dir(1).nb_avg>enum.dataset.slc(1).b(2).dir(1).nb_avg) % there is more b0 than b-values therefore it's T2 values
    enum.dataset.slc(1).b(1).dir(1).nb_avg=enum.dataset.slc(1).b(2).dir(1).nb_avg;
    DcmB0_T2=Dcm(:,:,1,1,1,enum.dataset.slc(1).b(2).dir(1).nb_avg:end);
    Dcm(:,:,1,1,1,enum.dataset.slc(1).b(2).dir(1).nb_avg:end)=nan;
end

%%
%%%%%%%%%%%%%%% Unmosaic %%%%%%%%%
if UI.mosa_mode && enum.mosa>1
    [Dcm, enum]= DiffRecon_ToolBox.Demosa_KM(Dcm, enum);
    save(fullfile(enum.recon_dir ,'Demosa.mat'),'Dcm','enum');
    if UI.gif_mode
        DiffRecon_ToolBox.Gif_KM(Dcm, enum, 'Unmosaic')
    end
end

%%
%%%%%%%%%%%%%%% Registration Before %%%%%%%%%
if UI.rigid_mode
    [Dcm]= DiffRecon_ToolBox.RigidRegistration_before_KM(Dcm, enum);
    save(fullfile(enum.recon_dir ,'Rigid2.mat'),'Dcm','enum');
    if UI.gif_mode
        DiffRecon_ToolBox.Gif_KM(Dcm, enum, 'RigidReg')
    end
end

if UI.Nrigid_mode
    [Dcm]= DiffRecon_ToolBox.NonRigidRegistration_KM(Dcm, enum);
    save(fullfile(enum.recon_dir ,'NonRigid.mat'),'Dcm','enum');
    if UI.gif_mode
        DiffRecon_ToolBox.Gif_KM(Dcm, enum, 'NonRigidReg')
    end
end



%%
%%%%%%%%%%%%%%% PCA %%%%%%%%%
if UI.pca_mode
    [Dcm ]= DiffRecon_ToolBox.VPCA_KM(Dcm,enum,80);
    save(fullfile(enum.recon_dir , 'PCA.mat'),'Dcm','enum');
end

%%
%%%%%%%%%%%%%%% tMIP %%%%%%%%%
if UI.tmip_mode
    [Dcm enum]= DiffRecon_ToolBox.tMIP_KM(Dcm, enum);
    save(fullfile(enum.recon_dir , 'tMIP.mat'),'Dcm','enum');
     if UI.gif_mode
        DiffRecon_ToolBox.Gif_KM(Dcm, enum, 'tMIP')
    end
end

%%
%%%%%%%%%%%%%%%% Average %%%%%%%%%
if UI.avg_mode   
    [Dcm enum]= DiffRecon_ToolBox.Average_KM(Dcm, enum); 
    save(fullfile(enum.recon_dir ,'Average.mat'),'Dcm','enum');
    if UI.gif_mode
        DiffRecon_ToolBox.Gif_KM(Dcm, enum, 'Average')
    end
end

%%
%%%%%%%%%%%%%%%% Average and reject %%%%%%%%%
if UI.avg2_mode 
    [Dcm  enum]= DiffRecon_ToolBox.Average_and_Reject_KM(Dcm, enum,4e-3);
    save(fullfile(enum.recon_dir ,'Average_Reject.mat'),'Dcm','enum');
     if UI.gif_mode
        DiffRecon_ToolBox.Gif_KM(Dcm, enum, 'Average_Reject')
    end
end
%%
%%%%%%%%%%%%%%% Registration After %%%%%%%%%
if UI.rigid_mode
    [Dcm]= DiffRecon_ToolBox.RigidRegistration_KM(Dcm, enum);
    save(fullfile(enum.recon_dir ,'RigidAfter.mat'),'Dcm','enum');
    if UI.gif_mode
        DiffRecon_ToolBox.Gif_KM(Dcm, enum, 'RigidReg')
    end
end

%%
%%%%%%%%%%%%%%% Zero filling interpolation %%%%%%%%%
if UI.inter_mode
   % [Dcm2 enum]= Depolation_KM(Dcm, enum);

   [Dcm enum]= DiffRecon_ToolBox.Interpolation_KM(Dcm, enum);
    save(fullfile(enum.recon_dir ,'Interpolation.mat'),'Dcm','enum');
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
    save(fullfile(enum.recon_dir ,'Trace.mat'),'Trace','Trace_Norm','enum');  
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
    save(fullfile(enum.recon_dir, 'ADC.mat'),'ADC');
end


%%
%%%%%%%%%%%%%%% Create Mask %%%%%%%%%
if UI.mask_mode
    [Mask]= DiffRecon_ToolBox.Mask_KM(Trace(:,:,:,2),60,60000);
    Mask(Mask>0)=1;
    %Dcm=Apply_Mask_KM(Dcm,Mask);
    save(fullfile(enum.recon_dir , 'Mask.mat'),'Mask','Dcm');  
end
%%
%%%%%%%%%%%%%%% Create ROI %%%%%%%%%
if UI.roi_mode    
     if isfile(fullfile(enum.recon_dir ,'ROI.mat'))
     load (fullfile(enum.recon_dir ,'ROI.mat'));
     else   
         [P_Endo,P_Epi,LV_Mask,Mask_Depth]= DiffRecon_ToolBox.ROI_KM(Trace(:,:,:,2));
        [Mask_AHA] = DiffRecon_ToolBox.ROI2AHA_KM (Dcm, P_Endo, P_Epi,LV_Mask);
        %Dcm=Apply_Mask_KM(Dcm,LV_mask);
        save(fullfile(enum.recon_dir ,'ROI.mat'),'P_Endo','P_Epi','LV_Mask','Mask_AHA','Mask_Depth');
     end
end
%%
%%%%%%%%%%%%%%% Calculate Tensor %%%%%%%%%
if UI.DTI_mode
    [Tensor,EigValue,EigVector,MD,FA,Trace_DTI] = DiffRecon_ToolBox.Calc_Tensor_KM(Dcm, enum);
    save(fullfile(enum.recon_dir ,'DTI.mat'),'Tensor','EigValue','EigVector','MD','FA','Trace_DTI');  
    
   %%%%%%%%%%%%%% Extract HA %%%%%%%%%%%%%
    if UI.roi_mode
                
        EigVect1=[];
        EigVect2=[];
        EigVect3=[];
        Elevation=[];
        EigVect1(:,:,1:size(EigVector,3),:)=squeeze(EigVector(:,:,:,1,:,1));
        EigVect2(:,:,1:size(EigVector,3),:)=squeeze(EigVector(:,:,:,1,:,2));
        EigVect3(:,:,1:size(EigVector,3),:)=squeeze(EigVector(:,:,:,1,:,3));
        Elevation(:,:,1:size(EigVector,3),:)=squeeze(EigVector(:,:,:,1,3,1));
        
        
        [HA TRA E2A]= DiffRecon_ToolBox.HA_E2A_KM(EigVect1, EigVect2, LV_Mask, P_Epi, P_Endo);

        [HA_filter]= DiffRecon_ToolBox.HA_Filter_KM(HA,LV_Mask ,Mask_Depth,0);
        [HA_filter2]= DiffRecon_ToolBox.HA_Filter_KM(HA_filter,LV_Mask ,Mask_Depth,0);
        save(fullfile(enum.recon_dir ,'HA.mat'),'EigVect1','EigVect2','EigVect3','Elevation','HA','TRA','HA_filter','HA_filter2','E2A');        
        
        % DTI2VTK_KM(EigVector,LV_Mask, enum,1,[],'test',[1 1 1]); % Uncomment to export fiber to
        % VTK
    end
end
%%
% if UI.ADC_mode  && UI.trace_mode 
%     [Folder]= Recreate_Dicom_Maps_KM(ADC*1e6.*Mask,enum,[],'ADCMap',1015);
% 	Recreate_Dicom_Maps_KM(Trace*1e1.*Mask,enum,Folder,'TraceMap',1016);
% end


%%
warning on;