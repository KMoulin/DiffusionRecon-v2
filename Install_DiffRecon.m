% Determine where your m-file's folder is.
folder = fileparts(which('Install_DiffRecon.m')); 
% Add that folder plus all subfolders to the path.
addpath(genpath(fullfile(folder,'Registration')));
addpath(genpath(fullfile(folder,'Script_Recon')));
addpath(genpath(fullfile(folder,'Batch_Recon')));
savepath;