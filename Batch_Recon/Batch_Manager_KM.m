
function Batch_Manager_KM

%%

     warning off;
     ColumName= [{'Run Batch' };{'Patient'};{'SerieNumber'}; {'Nb_Images'};{'Already Batched?'};{'Batch ROI found?'};{'ROI from old Recon found?'};{'Redo Batch ROI?'};{'Use previous ROI?'}; {'Serie Description'}; {'Manufacturer'}; {'Dicom Recon'}];  
   
    
    Batch_loaded=false;
    UI_created=false;
    Batch_struct=[];
    Batch_struct.struct_diff=[];
    Batch_struct.struct_update=[];
    Batch_struct.UI=[];
    Batch_struct.DataUI={};
    Batch_struct.dcm_dir = [];
    Batch_struct.name = 'none';
    
    FigH = figure('Units', 'normal', 'Position', [0.1 0.1 .8 .8]);  %not quite full screen  %[left bottom width height]
    
    RedStyle = uistyle('BackgroundColor',[1 0.6 0.6]);
    GreenStyle = uistyle('BackgroundColor',[0.6 1 0.6]);


    subgroup_button     = uipanel('Parent', FigH, 'Units', 'normal', 'Position', [0 0 1 1/5]);      
    subgroup_table = uipanel('Parent', FigH, 'Units', 'normal', 'Position', [0 1/5 1 1]);  
    
    uit=uitable(FigH,'Data',Batch_struct.DataUI, 'ColumnEditable', [true, false, false, false, false, false,false,true,true,false,false,false ],'Parent', subgroup_table, 'Units', 'normal','position', [0.01 0.01  0.98 0.79], 'CellEditCallback', @cb_cellchanged);
    uit.RowName = 'numbered';
    uit.ColumnName=ColumName;
    uit.ColumnWidth={100,240,100,100,100,100,100,100,100,240,100,100};
    
    New_button     = uicontrol('Style', 'pushbutton', 'String', 'New Batch'  ,'Parent', subgroup_button,  'Units', 'normal','Position', [0.05 0.5  0.25 0.3], 'Callback', @callback_New);
    Load_button        = uicontrol('Style', 'pushbutton', 'String', 'Load Batch','Parent', subgroup_button,  'Units', 'normal','Position', [0.3 0.5  0.25 0.3], 'Callback', @callback_Load);
    Update_button         = uicontrol('Style', 'pushbutton', 'String', 'Update Batch'  ,'Parent', subgroup_button,  'Units', 'normal','Position', [0.05 0.2  0.25 0.3], 'Callback', @callback_Update);
    Options_button         = uicontrol('Style', 'pushbutton', 'String', 'Recon Options'  ,'Parent', subgroup_button,  'Units', 'normal','Position', [0.3 0.2  0.25 0.3], 'Callback', @callback_Options);
    
    Run_button       = uicontrol('Style', 'pushbutton', 'String', 'Run Batch'  ,'Parent', subgroup_button,  'Units', 'normal','Position', [0.70 0.5  0.125 0.3], 'Callback', @callback_Run);
    Roi_button         = uicontrol('Style', 'pushbutton', 'String', 'ROI Batch'  ,'Parent', subgroup_button,  'Units', 'normal','Position', [0.70 0.2 0.125 0.3], 'Callback', @callback_ROI);
    AddScript_button         = uicontrol('Style', 'pushbutton', 'String', 'Additional Script'  ,'Parent', subgroup_button,  'Units', 'normal','Position', [0.825 0.2 0.125 0.3], 'Callback', @callback_addScript);
    Dicom_button         = uicontrol('Style', 'pushbutton', 'String', 'Dicom Batch'  ,'Parent', subgroup_button,  'Units', 'normal','Position', [0.825 0.5 0.125 0.3], 'Callback', @callback_dicom);
    Select_button         = uicontrol('Style', 'checkbox', 'String', 'Select all'  ,'Parent', subgroup_button,  'Units', 'normal','Position', [0.05 0.8 0.125 0.1], 'Callback', @callback_select);

    
     
function callback_Run(source, eventdata)
    Save_Batch();
    Run_Batch();
    Run_Dicom_Batch();
    Save_Batch();
end
function callback_ROI(source, eventdata)
    Run_ROI_Batch();
    Run_Dicom_Batch();
    Save_Batch();
end
function callback_addScript(source, eventdata)
    Run_add_Script_Batch();
    Run_Dicom_Batch();
    Save_Batch();
end
function callback_dicom(source, eventdata)
    Run_Dicom_Batch();
    Save_Batch();
end
function callback_select(source, eventdata)
    Select_Batch(source.Value);
    Update_Batch_Table();
end
function callback_New(source, eventdata)
    New_Batch();
    Create_UI();
    Update_Batch_Table();
    Save_Batch();
    
end
function callback_Load(source, eventdata)
    Load_Batch();
    Create_UI();
    Update_Batch_Table();
    
end
function callback_Update(source, eventdata)
    if Batch_loaded
       Update_Batch();
       Update_Batch_Table();
       Save_Batch();
    end
end
function callback_Options(source, eventdata)
    if Batch_loaded
        Batch_struct.UI=UIDiffRecon_KM(true,Batch_struct.UI);
        Save_Batch();
    end
end

   
function cb_cellchanged (hObject, callbackdata)
       % app.Lamp.Color = ~app.Lamp.Color;
        r = callbackdata.Indices(1);
        c = callbackdata.Indices(2);
      
     
        hObject.Data{r,c} = callbackdata.EditData;
        if c==8
            if hObject.Data{r,9} & hObject.Data{r,8}  
                hObject.Data{r,9}=false;
            end
        end

        if c==9
            if hObject.Data{r,9} & hObject.Data{r,8}  
                hObject.Data{r,8}=false;
            end
        end 
        
       Update_View();
        % app.Multiregs{r,c} = callbackdata.EditData;
       
        
end
function Select_Batch(val)
    if Batch_loaded   
            for cpt_diff=1:size(uit.Data,1)
                uit.Data{cpt_diff,1}= boolean(val); 
            end
             Update_Batch_Table();
    end
end
function Run_Batch

    if Batch_loaded
    
        for cpt_diff=1:length(Batch_struct.struct_diff)
            
          if Batch_struct.struct_diff(cpt_diff).runBatch  
              
                mkdir(fullfile(Batch_struct.dcm_dir , 'Batch_Recon'));
                mkdir(Batch_struct.struct_diff(cpt_diff).ReconFolder);


                % Do we have an old ROI and we want to keep it ?
                Batch_struct.UI.loadROI_old=(Batch_struct.struct_diff(cpt_diff).useExROI & Batch_struct.struct_diff(cpt_diff).hasROI_old & ~Batch_struct.struct_diff(cpt_diff).hasROI_current);
                
                % Do we have an new ROI and we don't want to redo it ?
                Batch_struct.UI.loadROI_current= (Batch_struct.struct_diff(cpt_diff).useExROI & Batch_struct.struct_diff(cpt_diff).hasROI_current & ~Batch_struct.struct_diff(cpt_diff).redoROI);
                try
                    script_batch_cDTI_KM(Batch_struct.struct_diff(cpt_diff),Batch_struct.UI);
                     Batch_struct.struct_diff(cpt_diff).hasError=false;
                catch
                    disp(['Problem with ' Batch_struct.struct_diff(cpt_diff).Patient ' serie ' num2str(Batch_struct.struct_diff(cpt_diff).SerieNumber)]);
                    Batch_struct.struct_diff(cpt_diff).hasError=true;
                end
               
                Update_Batch_Table();
          end
            
        end
    
    end
end
function Run_ROI_Batch

    if Batch_loaded
    
        for cpt_diff=1:length(Batch_struct.struct_diff)
           % Do we have an old ROI and we want to keep it ?
           Batch_struct.UI.loadROI_old=(Batch_struct.struct_diff(cpt_diff).useExROI & Batch_struct.struct_diff(cpt_diff).hasROI_old & ~Batch_struct.struct_diff(cpt_diff).hasROI_current);
                
           % Do we have an new ROI and we don't want to redo it ?
           Batch_struct.UI.loadROI_current= (Batch_struct.struct_diff(cpt_diff).useExROI & Batch_struct.struct_diff(cpt_diff).hasROI_current & ~Batch_struct.struct_diff(cpt_diff).redoROI);

          if Batch_struct.struct_diff(cpt_diff).runBatch && ~Batch_struct.struct_diff(cpt_diff).hasError 
              if ~((Batch_struct.struct_diff(cpt_diff).hasROI_current | Batch_struct.struct_diff(cpt_diff).hasROI_old) & ~Batch_struct.struct_diff(cpt_diff).redoROI)
                script_batch_ROI_KM(Batch_struct.struct_diff(cpt_diff));
                Update_Batch_Table();
              end
          end
            
        end
    end
end   
function Run_Dicom_Batch

    if Batch_loaded
        for cpt_diff=1:length(Batch_struct.struct_diff)
                  if Batch_struct.struct_diff(cpt_diff).runBatch && ~Batch_struct.struct_diff(cpt_diff).hasError 
                      try
                         script_batch_DICOM_KM(Batch_struct.struct_diff(cpt_diff));
                         Batch_struct.struct_diff(cpt_diff).hasDicomError=false;
                      catch
                         disp(['Problem with DICOM Recon ' Batch_struct.struct_diff(cpt_diff).Patient ' serie ' num2str(Batch_struct.struct_diff(cpt_diff).SerieNumber)]);
                         Batch_struct.struct_diff(cpt_diff).hasDicomError=true;
                      end
                      Update_Batch_Table();
                  end   
        end
    end
end
 function Run_add_Script_Batch

    if Batch_loaded
    
        for cpt_diff=1:length(Batch_struct.struct_diff)
         
          if Batch_struct.struct_diff(cpt_diff).runBatch 
                script_add_batch_KM(Batch_struct.struct_diff(cpt_diff)); 
          end
            
        end    
    end
end   
 
function New_Batch
    
    
        [batch_file,batch_path] = uiputfile('*.mat','Workspace File');
        
        Batch_struct=[];
        Batch_struct.UI=[];
        Batch_struct.struct_diff=[];
        Batch_struct.name=batch_file;
        Batch_struct.DataUI={};
        Batch_struct.dcm_dir = batch_path;
        
        
        Batch_struct.UI=UIDiffRecon_KM(true);
       
   
        listing=dir(fullfile(Batch_struct.dcm_dir, '**'));
        listing=listing(~[listing.isdir]);  % Remove folder

        listing_folder=str2mat(listing.folder); % we store the folder somewhere.
        listing_folder=string(listing_folder);

        listing_folder=unique(listing_folder); % we keep the folder that are unique.

        listing_dcm=[];
        for cpt_folder=1:length(listing_folder)

            listing_dcm=[listing_dcm; dir(listing_folder(cpt_folder))];
           %
        end

        [struct_diff, struct_final, ListNames, ListSeries]=Analyze_Content_local(listing_dcm,[]); % Create a brand new list_update;
          
        Batch_struct.struct_diff=struct_diff;
        Batch_struct.struct_update=struct_final;
        Batch_struct.DataUI = Struct2DataUI(struct_diff);

        Batch_loaded=true;
end
   
function Load_Batch
      
        [file path]=uigetfile('.mat');
        load(fullfile(path , file));
        Batch_loaded=true;
end

    
function Save_Batch
      if Batch_loaded
          save(fullfile(Batch_struct.dcm_dir , Batch_struct.name),'Batch_struct');
      end
end
function Create_UI
     if Batch_loaded
        Batch_struct.DataUI=Struct2DataUI(Batch_struct.struct_diff);
        uit.Data=Batch_struct.DataUI;
        UI_created=true;
     end
end
function Update_Batch_Table
     if Batch_loaded
        
         if UI_created % we update the batch from the UI only if the UI already exist
            Batch_struct.struct_diff=DataUI2Struct(Batch_struct.struct_diff,uit.Data);
         end
        for cpt_diff=1:length(Batch_struct.struct_diff)
             
                fullfile(string(Batch_struct.dcm_dir),'Batch_Recon','Maps_'+string(Batch_struct.struct_diff(cpt_diff).Patient)+'_'+Batch_struct.struct_diff(cpt_diff).SerieNumber+'_'+string(Batch_struct.name(1:end-4)));
                Batch_struct.struct_diff(cpt_diff).ReconFolder=fullfile(string(Batch_struct.dcm_dir),'Batch_Recon','Maps_'+string(Batch_struct.struct_diff(cpt_diff).Patient)+'_'+Batch_struct.struct_diff(cpt_diff).SerieNumber+'_'+string(Batch_struct.name(1:end-4)));
                Batch_struct.struct_diff(cpt_diff).ReconDcmFolder=fullfile(string(Batch_struct.dcm_dir),'Dicom_Recon','Maps_'+string(Batch_struct.struct_diff(cpt_diff).Patient)+'_'+Batch_struct.struct_diff(cpt_diff).SerieNumber+'_'+string(Batch_struct.name(1:end-4)));
                Batch_struct.struct_diff(cpt_diff).DcmFolder=char(Batch_struct.struct_diff(cpt_diff).Listing(1).folder);


                listing=dir(fullfile(Batch_struct.struct_diff(cpt_diff).DcmFolder,'Maps','ROI*.mat'));
                Batch_struct.struct_diff(cpt_diff).hasROI_old=~isempty(listing);

                listing=dir(fullfile(string(Batch_struct.dcm_dir),'Batch_Recon','Maps_'+string(Batch_struct.struct_diff(cpt_diff).Patient)+'_'+string(Batch_struct.struct_diff(cpt_diff).SerieNumber),'*','ROI.mat'));
                Batch_struct.struct_diff(cpt_diff).hasROI_old_batch=~isempty(listing);
                Batch_struct.struct_diff(cpt_diff).old_batch_path=listing;
                
                listing=dir(fullfile(Batch_struct.struct_diff(cpt_diff).ReconFolder));
                Batch_struct.struct_diff(cpt_diff).hasBatch=~isempty(listing);

                listing=dir(fullfile(Batch_struct.struct_diff(cpt_diff).ReconFolder, 'ROI*.mat'));
                Batch_struct.struct_diff(cpt_diff).hasROI_current=~isempty(listing);
            
        end
        Batch_struct.DataUI=Struct2DataUI(Batch_struct.struct_diff);
        uit.Data=Batch_struct.DataUI;
     end
end
function Update_Batch
    if Batch_loaded
        listing=dir(fullfile(Batch_struct.dcm_dir, '**'));
        listing=listing(~[listing.isdir]);  % Remove folder

        listing_folder=str2mat(listing.folder); % we store the folder somewhere.
        listing_folder=string(listing_folder);

        listing_folder=unique(listing_folder); % we keep the folder that are unique.

        listing_dcm=[];
        
        folderAlreadySorted=[];
        
        
        for cpt=1:1:length(Batch_struct.struct_update)
                 LL=Batch_struct.struct_update(cpt).Listing;
                 folderAlreadySorted=[folderAlreadySorted string(unique(string({LL(:).folder})))]; 
        end
        folderAlreadySorted=deblank(folderAlreadySorted);
        % Idx=contains(folderAlreadySorted , 'Dicom_Recon' ); 
        % folderAlreadySorted(Idx)=[];

        for cpt_folder=1:length(listing_folder)
             if( ~contains(deblank(listing_folder(cpt_folder)) , folderAlreadySorted))
                listing_dcm=[listing_dcm; dir(listing_folder(cpt_folder))];
             end
           %
        end

        [struct_diff, struct_final, ListNames, ListSeries]=Analyze_Content_local(listing_dcm,Batch_struct.struct_update); % Create a brand new list_update;
          
        Batch_struct.struct_diff=struct_diff;
        Batch_struct.struct_update=struct_final;
        Batch_struct.DataUI = Struct2DataUI(struct_diff);
        uit.Data=Batch_struct.DataUI;
    end
end
function Update_View
     if Batch_loaded
        
         if UI_created % we update the batch from the UI only if the UI already exist
            Batch_struct.struct_diff=DataUI2Struct(Batch_struct.struct_diff,uit.Data);
         end
        Batch_struct.DataUI=Struct2DataUI(Batch_struct.struct_diff);
     end
end


function DataUI=Struct2DataUI(struct_diff)
    DataUI={};
    for cpt_diff=1:length(struct_diff)
                          % [{'Run Batch' };{'Patient'};  {'SerieNumber'}; {'Nb_Images'};{'Already Batched?'};{'Existing current ROI?'};{'Existing old ROI?'};{'Redo ROI?'};{'Use old ROI?'}];  
        DataUI(cpt_diff,:) = {struct_diff(cpt_diff).runBatch,char(struct_diff(cpt_diff).Patient),((struct_diff(cpt_diff).SerieNumber)),struct_diff(cpt_diff).Nb_Images,('No'),('No'),('No'),struct_diff(cpt_diff).redoROI,struct_diff(cpt_diff).useExROI,struct_diff(cpt_diff).SerieDescription,struct_diff(cpt_diff).Manufacturer,('No')}; 
       %  struct_diff(cpt_diff).runBatch
      % struct_diff(cpt_diff).redoROI
       %struct_diff(cpt_diff).useROI_old
        if struct_diff(cpt_diff).hasError
             DataUI(cpt_diff,5)={'Error'};
        else
            if struct_diff(cpt_diff).hasBatch %5
                 DataUI(cpt_diff,5)={'Yes'};
            else
                 DataUI(cpt_diff,5)={'No'};
            end
        end
        if struct_diff(cpt_diff).hasROI_current %6
            DataUI(cpt_diff,6)={'Yes'};
        else
             DataUI(cpt_diff,6)={'No'};
        end
        
        if struct_diff(cpt_diff).hasROI_old | struct_diff(cpt_diff).hasROI_old_batch %7
            DataUI(cpt_diff,7)={'Yes'};
        else
             DataUI(cpt_diff,7)={'No'};
        end
    
        if struct_diff(cpt_diff).hasDicomError
             DataUI(cpt_diff,12)={'Error'};
        else
            if struct_diff(cpt_diff).hasDicomMaps %7
                DataUI(cpt_diff,12)={'Yes'};
            else
                 DataUI(cpt_diff,12)={'No'};
            end
        end
    
    end
                 
end
function struct_diff=DataUI2Struct(struct_diff,DataUI)

    
    for cpt_diff=1:length(struct_diff)
        
        
       % [{'Run Batch' };{'Patient'};  {'SerieNumber'}; {'Nb_Images'};{'Already Batched?'};{'Existing current ROI?'};{'Existing old ROI?'};{'Redo ROI?'};{'Use old ROI?'}];  
        struct_diff(cpt_diff).runBatch=cell2mat(DataUI(cpt_diff,1));
        struct_diff(cpt_diff).redoROI= cell2mat(DataUI(cpt_diff,8)); %8
        struct_diff(cpt_diff).useExROI = cell2mat(DataUI(cpt_diff,9));%9
    end
                 
end

function [struct_diff, struct_final, ListNames, ListSeries] =Analyze_Content_local(listing, struct_final)

    %listing = dir(dcm_dir);
   
    struct=[];
 
    ListNames={};
    ListSeries={};
    
    ListStudyUID={};
    ListSerieUID={};
    cpt_series=0;
    cpt_name=0;
    k=1;
    h = waitbar(0,'Analyzing the folders...');
    for cpt=1:1:size(listing,1)   
            if ~listing(cpt).isdir & isempty(strfind(listing(cpt).folder,'Batch_Recon'))
                                
                 [FolderName, name, fExt] = fileparts(listing(cpt).name);
        
                if (strcmp(fExt, '.dcm') | strcmp(fExt, '.IMA') | isempty(fExt))  & ~ strcmp('DICOMDIR',listing(cpt).name) 
                    tmpInfo=dicominfo(fullfile(listing(cpt).folder , listing(cpt).name));
                    %tmpDcm=dicomread([listing(cpt).folder '\' listing(cpt).name]);
                    %Dcm(:,:,k)=double(dicomread(listing(cpt).name));
                    %Dcm(k)=tmpInfo.SeriesNumber;
                    k=k+1;
                    tmpStudyInstance='NA';
                    if isfield(tmpInfo,'StudyInstanceUID')
                        tmpStudyInstance=tmpInfo.StudyInstanceUID;
                    end  
                    tmpImageType='NA';
                    if isfield(tmpInfo,'ImageType')
                        tmpImageType=tmpInfo.ImageType;
                    end  
                    
                    if isempty(find(strcmp(ListStudyUID,tmpStudyInstance))) 
                            ListStudyUID{end+1}=tmpStudyInstance; 
                            cpt_name=find(strcmp(ListStudyUID,tmpStudyInstance));
                            ListSerieUID{cpt_name}.List=[];
                    end
                    cpt_name=find(strcmp(ListStudyUID,tmpStudyInstance));
                    
                    tmp_serie=tmpInfo.SeriesNumber;
                    if(~isempty(strfind(tmpImageType,'MFSPLIT')) )
                        tmp_serie=tmp_serie+500;
                    else
                        if isfield(tmpInfo,'AcquisitionTime')
                            if isempty(tmpInfo.AcquisitionTime)
                                 tmp_serie=tmp_serie+500;
                            end
                        else
                            tmp_serie=tmp_serie+500;
                        end
                    end
                    if isempty(find((ListSerieUID{cpt_name}.List==tmp_serie))) 
                        
                        ListSerieUID{cpt_name}.List= [ListSerieUID{cpt_name}.List tmp_serie]   ;
                        cpt_series=find((ListSerieUID{cpt_name}.List==tmp_serie));
                        %struct(cpt_name).series(cpt_series).Dcm=[];
                         struct(cpt_name).series(cpt_series).Listing=[];
                    end
                    cpt_series=find((ListSerieUID{cpt_name}.List==tmp_serie));

                    % Build the dicom structure
                    bdiff=~isempty(strfind(tmpImageType,'DIFFUSION'));
                    btr=~isempty(strfind(tmpImageType,'TRACEW'));
                    btr0=~isempty(strfind(tmpImageType,'TENSOR_B0'));
                    brgb=~isempty(strfind(tmpImageType,'RGB'));
                    badc=~isempty(strfind(tmpImageType,'ADC'));
                    bfa=~isempty(strfind(tmpImageType,'FA'));
                    bten=~isempty(strfind(tmpImageType,'TENSOR'))&isempty(strfind(tmpImageType,'TENSOR_B0'));
                    
                    if ~isfield (tmpInfo,'PatientID')
                         if isfield (tmpInfo,'OtherPatientID')
                            tmpInfo.PatientID=tmpInfo.OtherPatientID;
                         else
                            tmpInfo.PatientID=tmpInfo.StudyInstanceUID;
                         end
                    end
                    if isfield (tmpInfo,'SeriesDate')
                        struct(cpt_name).name=[tmpInfo.PatientID '_' tmpInfo.SeriesDate] ;
                        struct(cpt_name).series(cpt_series).Patient= [tmpInfo.PatientName.FamilyName '_' tmpInfo.SeriesDate] ;
                    else
                        struct(cpt_name).name=tmpInfo.PatientID;
                         struct(cpt_name).series(cpt_series).Patient= tmpInfo.PatientName.FamilyName;
                    end
       
                    struct(cpt_name).series(cpt_series).SerieNumber=tmp_serie;                  
                     %tmpInfo.PatientID;
                    if isfield(tmpInfo,'ProtocolName')
                        struct(cpt_name).series(cpt_series).SerieDescription=tmpInfo.ProtocolName;
                    else
                        struct(cpt_name).series(cpt_series).SerieDescription='NA';
                    end
                     if isfield(tmpInfo,'Manufacturer')
                        struct(cpt_name).series(cpt_series).Manufacturer=tmpInfo.Manufacturer;
                    else
                        struct(cpt_name).series(cpt_series).Manufacturer='NA';
                     end
                    
                    struct(cpt_name).series(cpt_series).StudyUID=tmpStudyInstance;
                    struct(cpt_name).series(cpt_series).SerieUID=tmpInfo.SeriesInstanceUID;
                    %struct(cpt_name).series(cpt_series).Dcm(:,:,end+1)=tmpDcm(:,:,1);
                    
                    struct(cpt_name).series(cpt_series).Listing(end+1).name=listing(cpt).name;
                    struct(cpt_name).series(cpt_series).Listing(end).folder=listing(cpt).folder;
                    struct(cpt_name).series(cpt_series).Listing(end).isdir=0;
                    struct(cpt_name).series(cpt_series).Nb_Images=length(struct(cpt_name).series(cpt_series).Listing);
                    struct(cpt_name).series(cpt_series).isdiff=bdiff;
                    struct(cpt_name).series(cpt_series).istracew=btr;
                    struct(cpt_name).series(cpt_series).istraceb0=btr0;
                    struct(cpt_name).series(cpt_series).RGB=brgb;
                    struct(cpt_name).series(cpt_series).isadc=badc;
                    struct(cpt_name).series(cpt_series).isfa=bfa;
                    struct(cpt_name).series(cpt_series).istensor=bten;
                     if isfield(tmpInfo,'Manufacturer')  
                        if ~isempty(strfind(lower(tmpInfo.Manufacturer),'siemens'))
                            struct(cpt_name).series(cpt_series).isdwi= bdiff & ~btr & ~btr0 & ~badc & ~bfa & ~bten;
                        else
                            struct(cpt_name).series(cpt_series).isdwi=1;
                        end
                     else
                         struct(cpt_name).series(cpt_series).isdwi=0;
                     end
                    
                    struct(cpt_name).series(cpt_series).hasError=false;
                    struct(cpt_name).series(cpt_series).hasDicomError=false;
                    struct(cpt_name).series(cpt_series).hasDicomMaps=true;    
                    struct(cpt_name).series(cpt_series).runBatch=true;
                    struct(cpt_name).series(cpt_series).hasROI_current=false;
                    struct(cpt_name).series(cpt_series).hasROI_old=false;
                    struct(cpt_name).series(cpt_series).hasROI_old_batch=false;
                    struct(cpt_name).series(cpt_series).hasBatch=false;
                    struct(cpt_name).series(cpt_series).redoROI=false;
                    struct(cpt_name).series(cpt_series).useExROI=true;
                    
                end
            end
            waitbar(cpt/size(listing,1),h,['Analyzing the folders... (Patient ' num2str(cpt_name) ', Serie '  num2str(cpt_series) ')' ] );  
    end
    close(h)
    
    for cpt_serie=1:length(struct)
        struct_final=[struct_final struct(cpt_serie).series];
    end
    
    
    struct_diff=struct_final(find([struct_final.isdwi]));    
    struct_Ndiff=struct_final(find(~[struct_final.isdwi]));
    for cpt_diff=1:1:length(struct_diff)
         struct_diff(cpt_diff).hasDicomMaps=true;
    end

end

end