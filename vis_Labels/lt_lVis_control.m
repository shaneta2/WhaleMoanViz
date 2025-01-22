function lt_lVis_control(action,NFile)

%updates in response to GUI changes

global REMORA HANDLES PARAMS


if strcmp(action,'LoadLabels')
    % Get detection label file
    [filename, path]= uigetfile('*.txt','Select detection labels file');
    % if canceled button pushed:
    if strcmp(num2str(filename),'0')
        return
    end
    fileFullPath = fullfile(path, filename);
    
    REMORA.lt.lVis_det.fileFullPath = fileFullPath;  % Store the file path globally
  
    data = readtable(fileFullPath);
    
    % Sort by the 'start_time' column
    data = sortrows(data, 'start_time');

    data.start_time = datetime(data.start_time, 'InputFormat', 'yyyy-MM-dd HH:mm:ss');
    data.end_time = datetime(data.end_time, 'InputFormat', 'yyyy-MM-dd HH:mm:ss');
    excelEpoch = datetime(2000, 1, 0); % Triton datetime format
    Starts_time = data.start_time;
    Starts = days(Starts_time - excelEpoch); % Convert Start and Stop columns to datetime and calculate days since epoch
    Stops_time = data.end_time;
    Stops = days(Stops_time - excelEpoch); % Convert Start and Stop columns to datetime and calculate days since epoch

    Labels = data.label;
    % add frequency and score
    
    % Check if the 'pr' column exists; if not, initialize as true positives (1)
    if ~ismember('pr', data.Properties.VariableNames)
        data.pr = ones(height(data), 1); % Initialize all as true positives
    end

    % Save the data table to REMORA for global access
    REMORA.lt.lVis_det.dataTable = data;
    
    min_freq = data.min_frequency;
    max_freq = data.max_frequency;
    Score = data.score;
        
    % Ensure sorted
    if ~issorted(Starts)
        fprintf('Sorting labels...')
        [Starts, Permutation] = sort(Starts);
        Stops = Stops(Permutation);  % put Stops in new order
        fprintf('complete\n');
    end
    if strcmp(NFile,'labels1')
        REMORA.lt.lVis_det.detection.starts = Starts;
        REMORA.lt.lVis_det.detection.stops = Stops;
        REMORA.lt.lVis_det.detection.labels = Labels;
        REMORA.lt.lVis_det.detection.min_freq = min_freq;
        REMORA.lt.lVis_det.detection.max_freq = max_freq;
        REMORA.lt.lVis_det.detection.score = Score;
        REMORA.lt.lVis_det.detection.pr = ones(size(Starts));  % Start all as true positives
        % set to display labels
        REMORA.lt.lVis_det.detection.PlotLabels = true;
        set(REMORA.lt.lVis_labels.label1Check,'Value',1)
        % add file name to gui
        REMORA.lt.lVis_det.detection.files = {filename};
        set(REMORA.lt.lVis_labels.label1Check,'Enable','on')
        set(REMORA.lt.lVis_labels.label1Check,'String',filename)
        set(REMORA.lt.lVis_labels.label1Check,'BackgroundColor',[1 1 1])
        
        %initialize empty spots for change labels
        REMORA.lt.lEdit.detection = double.empty(0,3);
        REMORA.lt.lEdit.detectionLab = [];
        
        %calculate LTSA bouts
        %%% shorten detections to bout-level
        boutGap = datenum(0,0,0,0,0,15); %if spacing between start of detections...
        %is less than this, combine into a bout
        [REMORA.lt.lVis_det.detection.bouts.starts,REMORA.lt.lVis_det.detection.bouts.stops] = lt_lVis_defineBouts(...
            REMORA.lt.lVis_det.detection.starts, ...
            REMORA.lt.lVis_det.detection.stops, ...
            boutGap);
        
      
    end
    
    %refresh window
    plot_triton
    %which labels to display
   
    if HANDLES.display.specgram.Value
        lt_lVis_plot_WAV_labels
    end
    
    if HANDLES.display.timeseries.Value
        lt_lVis_plot_TS_labels
    end
    
    
elseif strcmp(action,'Display')
    if strcmp(NFile,'labels1')
        enabled = get(REMORA.lt.lVis_labels.label1Check,'Enable');
        if strcmp(enabled,'on')
            checked = get(REMORA.lt.lVis_labels.label1Check,'Value');
            if checked
                REMORA.lt.lVis_det.detection.PlotLabels = true;
            else
                REMORA.lt.lVis_det.detection.PlotLabels = false;
            end
        else
            return
        end
        
   
    end
    
    %refresh window
    plot_triton
    %which labels to display
  
    if HANDLES.display.specgram.Value
        lt_lVis_plot_WAV_labels
    end
    
    if HANDLES.display.timeseries.Value
        lt_lVis_plot_TS_labels
    end
    
    
    % back buttons
elseif strcmp(action, 'TakeItBack')
   
    if HANDLES.display.specgram.Value
        lt_lVis_plot_WAV_labels
    end
    
    if HANDLES.display.timeseries.Value
        lt_lVis_plot_TS_labels
    end
    
elseif strcmp(action, 'SmallStepBack')
    motion('back');
    if HANDLES.display.specgram.Value
        lt_lVis_plot_WAV_labels
    end
    if HANDLES.display.timeseries.Value
        lt_lVis_plot_TS_labels
    end
    
elseif strcmp(action, 'PrevDetection')
    motion('prevDet');
    if HANDLES.display.specgram.Value
        lt_lVis_plot_WAV_labels
    end
    if HANDLES.display.timeseries.Value
        lt_lVis_plot_TS_labels
    end
    
    % forward buttons
elseif strcmp(action, 'MoveAlong')
    
    if HANDLES.display.specgram.Value
        lt_lVis_plot_WAV_labels
    end
    if HANDLES.display.timeseries.Value
        lt_lVis_plot_TS_labels
    end
    
elseif strcmp(action, 'OneStepForward')
    motion('forward');
    if HANDLES.display.specgram.Value
        lt_lVis_plot_WAV_labels
    end
    if HANDLES.display.timeseries.Value
        lt_lVis_plot_TS_labels
    end
    
    
elseif strcmp(action, 'NextDetection')
    motion('nextDet');
    if HANDLES.display.specgram.Value
        lt_lVis_plot_WAV_labels
    end
    if HANDLES.display.timeseries.Value
        lt_lVis_plot_TS_labels
    end
    
elseif strcmp(action, 'AddDetection')
    % Call function to set up adding a new detection
    enterAddDetectionMode();
    
    %refresh buttons
elseif strcmp(action, 'SaveEdits')
    
    saveEditedDetections(REMORA.lt.lVis_det.fileFullPath);
    %which labels to display

    if HANDLES.display.specgram.Value
        lt_lVis_plot_WAV_labels
    end
    
    if HANDLES.display.timeseries.Value
        lt_lVis_plot_TS_labels
    end
end
 
if ~isempty(PARAMS.infile)
    set(REMORA.lt.lVis_labels.RFfwd,'Enable',...
        get(HANDLES.motion.fwd,'Enable'));
    set(REMORA.lt.lVis_labels.nextF,'Enable',...
        get(HANDLES.motion.nextfile,'Enable'));
    set(REMORA.lt.lVis_labels.RFback,'Enable',...
        get(HANDLES.motion.back,'Enable'));
    set(REMORA.lt.lVis_labels.prevF,'Enable',...
        get(HANDLES.motion.prevfile,'Enable'));
end

end 