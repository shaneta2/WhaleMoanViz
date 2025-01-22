function finalizeEditMode(event)
    global REMORA HANDLES PARAMS

    % Retrieve detection index and rectangle information
    detectionIdx = REMORA.lt.lVis_det.currentEdit.detectionIdx;
    editedRect = REMORA.lt.lVis_det.currentEdit.editedRect;
    label = REMORA.lt.lVis_det.currentEdit.label;  % Retrieve label from currentEdit
    
    % Check if the Enter key was pressed (to save edits)
    if strcmp(event.Key, 'return') || strcmp(event.Key, 'enter')
        disp('Enter key detected! Saving modified bounding box.');
        
        % Convert editedRect position to absolute datenums
        pos = editedRect.Position;
        startWV = PARAMS.plot.dnum;  % Spectrogram window start time in datenum format
        
        excelEpoch = datetime(2000, 1, 0);  % Reference epoch
        % Calculate absolute start and end times
        % Calculate absolute start and end times in "days since epoch"
        startTimeDays = startWV + pos(1) / (24 * 3600);  % Convert seconds to days
        endTimeDays = startWV + (pos(1) + pos(3)) / (24 * 3600);  % Duration in seconds to days
        
       
        
        % Convert days since epoch to datetime format for the main data table
        startTime = excelEpoch + days(startTimeDays); 
        endTime = excelEpoch + days(endTimeDays);
        
        % Calculate start and end times in seconds relative to the beginning of the WAV file
        
        % Convert the WAV start time to datetime format
        wav_start_time_days = PARAMS.raw.dnumStart;  % Start time in datenum format
        wav_start_datetime = excelEpoch + days(wav_start_time_days);  % Convert to datetime

        % Calculate start time in seconds relative to the WAV file start
        start_time_sec = seconds(startTime - wav_start_datetime);  % Time difference in seconds
        end_time_sec = seconds(endTime - wav_start_datetime);  % Time difference in seconds

        minFreq = pos(2);
        maxFreq = pos(2) + pos(4);

        % Update main data table with edited values
        REMORA.lt.lVis_det.dataTable.start_time(detectionIdx) = startTime;
        REMORA.lt.lVis_det.dataTable.end_time(detectionIdx) = endTime;
        REMORA.lt.lVis_det.dataTable.min_frequency(detectionIdx) = minFreq;
        REMORA.lt.lVis_det.dataTable.max_frequency(detectionIdx) = maxFreq;
        REMORA.lt.lVis_det.dataTable.label{detectionIdx} = label;
        
        % Update detection fields
        initializeDetectionFields(REMORA.lt.lVis_det.dataTable);
        
        lt_lVis_plot_WAV_labels();
        % Clear the currentEdit data

    % Check if the Delete or Backspace key was pressed (to delete detection)
    elseif strcmp(event.Key, 'delete') || strcmp(event.Key, 'backspace')
        disp('Delete key detected! Marking as false positive.');

        % Mark detection as a false positive by setting pr to 2
        REMORA.lt.lVis_det.dataTable.pr(detectionIdx) = 2;
        
        initializeDetectionFields(REMORA.lt.lVis_det.dataTable);

        % Remove both the interactive and original rectangles from the display
        delete(editedRect);
        
        delete(REMORA.lt.lVis_det.currentEdit.originalRect);

        % Refresh the plot to remove the deleted detection
        lt_lVis_plot_WAV_labels();
    end

    % Clear the stored currentEdit data and remove the key press listener
    REMORA.lt.lVis_det.currentEdit = [];
    set(HANDLES.fig.main, 'WindowKeyPressFcn', '');
end
