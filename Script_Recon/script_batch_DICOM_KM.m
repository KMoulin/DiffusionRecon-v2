function script_batch_DICOM_KM(struct_diff)

    % Batch script meant for being called from the Batch_Manager. 
    % the script exepct a struct_diff 
    warning off;

   
    mkdir([struct_diff.ReconDcmFolder]);
    tmpMap=[];
    tmpRoi=[];
    tmpEnum=[];
    if isfile(fullfile(struct_diff.ReconFolder, 'Trace.mat'))
        tmpMap=load(fullfile(struct_diff.ReconFolder, 'Trace.mat'));
        tmpEnum=tmpMap.enum;
        Recon_Local_Dicom_Maps(struct_diff,(tmpMap.Trace./nanmax(tmpMap.Trace(:)))*4096,tmpEnum,'Trace',10000,[0 4096])
    end
    
    if isfile(fullfile(struct_diff.ReconFolder, 'ADC.mat'))
        tmpMap=load(fullfile(struct_diff.ReconFolder, 'ADC.mat'));
        Recon_Local_Dicom_Maps(struct_diff,tmpMap.ADC*1e6,tmpEnum,'ADC',20000,[0 5e-3*1e6])
    end
    
    
    if isfile(fullfile(struct_diff.ReconFolder, 'DTI.mat'))
        EigValue=[];
        tmpMap=load(fullfile(struct_diff.ReconFolder, 'DTI.mat'));
        Recon_Local_Dicom_Maps(struct_diff,tmpMap.MD*1e6,tmpEnum,'MD',30000,[0 5e-3*1e6]);
        Recon_Local_Dicom_Maps(struct_diff,(tmpMap.EigValue(:,:,:,:,2)+tmpMap.EigValue(:,:,:,:,3))*1e6/2,tmpEnum,'RD',40000,[0 5e-3*1e6]);
        Recon_Local_Dicom_Maps(struct_diff,tmpMap.FA*1e3,tmpEnum,'FA',50000,[0 1e3]);
    end
     
    if isfile(fullfile(struct_diff.ReconFolder, 'HA.mat')) && isfile(fullfile(struct_diff.ReconFolder, 'ROI.mat'))
        tmpMap=load(fullfile(struct_diff.ReconFolder, 'HA.mat'));
        tmpMap2=load(fullfile(struct_diff.ReconFolder, 'ROI.mat'));
        Recon_Local_Dicom_Maps(struct_diff,(tmpMap.HA_filter2+90)*1e1.*tmpMap2.LV_Mask,tmpEnum,'HA',60000,[0 180*1e1]);
        Recon_Local_Dicom_Maps(struct_diff,(tmpMap.TRA+90)*1e1.*tmpMap2.LV_Mask,tmpEnum,'TRA',70000,[0 180*1e1]);
        Recon_Local_Dicom_Maps(struct_diff,tmpMap.E2A*1e1,tmpEnum,'E2A',80000,[0 90*1e1]);
    end
     if isfile(fullfile(struct_diff.ReconFolder, 'HA.mat')) && isfile(fullfile(struct_diff.ReconFolder,'ROInet.mat'))
        tmpMap=load(fullfile(struct_diff.ReconFolder, 'HA.mat'));
        tmpMap2=load(fullfile(struct_diff.ReconFolder, 'ROInet.mat'));
        Recon_Local_Dicom_Maps(struct_diff,(tmpMap.HA_filter2+90)*1e1.*tmpMap2.LV_Mask,tmpEnum,'HA',60000,[0 180*1e1]);
        Recon_Local_Dicom_Maps(struct_diff,(tmpMap.TRA+90)*1e1.*tmpMap2.LV_Mask,tmpEnum,'TRA',70000,[0 180*1e1]);
        Recon_Local_Dicom_Maps(struct_diff,tmpMap.E2A*1e1,tmpEnum,'E2A',80000,[0 90*1e1]);
    end
    function Recon_Local_Dicom_Maps(struct_diff,Map,enum,MapName,Serie_Shift,scale)
      
      ListingMaps=[];
      

      uid = dicomuid;
      
      for cpt_slc=1:1:size(Map,3)
          uid2 = dicomuid;
          for cpt_b=1:1:size(Map,4)
                    
                   %tmpinfoDcm=dicominfo([ListingMaps(cpt_slc).folder '\' ListingMaps(cpt_slc).name]);       
                   tmpinfoDcm=dicominfo(fullfile(struct_diff.Listing(1).folder  , struct_diff.Listing(1).name));
                   tmpinfoDcm.SeriesDescription=[struct_diff.SerieDescription '_' MapName '_' num2str(cpt_b) '_KM'];
                   tmpinfoDcm.ImageType=MapName;
                   tmpinfoDcm.SmallestImagePixelValue=scale(1);
                   tmpinfoDcm.LargestImagePixelValue=scale(2);
                   tmpinfoDcm.WindowCenter=round((scale(2)-scale(1))/2);
                   tmpinfoDcm.WindowWidth=scale(2);
                   tmpinfoDcm.MediaStorageSOPInstanceUID=uid2;
                   tmpinfoDcm.SOPInstanceUID=uid2;
                   if(isfield(tmpinfoDcm,'ImagePositionPatient'))
                        tmpinfoDcm.ImagePositionPatient= tmpinfoDcm.ImagePositionPatient+[0 0 cpt_slc];
                   else
                       tmpinfoDcm.ImagePositionPatient= [0 0 cpt_slc];
                   end
                   if(isfield(tmpinfoDcm,'InstanceCreationTime'))
                        tmpinfoDcm.InstanceCreationTime=tmpinfoDcm.InstanceCreationTime+cpt_slc;
                   else
                       tmpinfoDcm.InstanceCreationTime=cpt_slc;
                   end
                   tmpinfoDcm.SliceLocation=enum.slc(cpt_slc);
                   tmpinfoDcm.SeriesNumber= struct_diff.SerieNumber+Serie_Shift+cpt_b-1;
                   tmpinfoDcm.SeriesInstanceUID=uid;
                   tmpinfoDcm.InstanceNumber=1;%cpt_slc;
                   tmpdataDcm=Map(:,:,cpt_slc,cpt_b);
                   
                   dicomwrite(uint16(tmpdataDcm),fullfile(struct_diff.ReconDcmFolder , [MapName '_slc' num2str(cpt_slc) '_Bval' num2str(cpt_b) '_KM.dcm']), tmpinfoDcm, 'CreateMode', 'copy', 'WritePrivate' ,true); 
                
          end
       end
        
    end
end