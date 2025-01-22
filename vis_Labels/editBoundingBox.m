function editBoundingBox(src, detectionIdx, startX, endX, minY, maxY, label, score, color)
    global REMORA HANDLES
    
    % Initialize edited_labels if it doesn't exist
    if ~isfield(REMORA.lt.lVis_det.detection, 'edited_labels') || isempty(REMORA.lt.lVis_det.detection.edited_labels)
        REMORA.lt.lVis_det.detection.edited_labels = {};  % Initialize as an empty cell array
    end

    % Enter edit mode by turning the selected rectangle into an interactive drawrectangle
    src.Visible = 'off';  % Hide original rectangle temporarily

    % Create an interactive rectangle in place of the original
    editedRect = drawrectangle('Position', [startX, minY, endX - startX, maxY - minY], ...
                               'Color', 'cyan', 'LineWidth', 2);
    disp('Interactive bounding box created.');

    % Save the initial rectangle properties in currentEdit
    REMORA.lt.lVis_det.currentEdit = struct( ...
        'originalRect', src, ...
        'editedRect', editedRect, ...  % Store edited rectangle handle
        'start_datenum', startX, ...
        'end_datenum', endX, ...
        'min_freq', minY, ...
        'max_freq', maxY, ...
        'label', label, ...
        'score', score, ...
        'detectionIdx', detectionIdx ...  % Store index directly
    );

    % Set up the KeyPressFcn to finalize with Enter key or Delete with Delete key
    set(HANDLES.fig.main, 'WindowKeyPressFcn', @(~, event) finalizeEditMode(event));    

    % Set up a listener for when the rectangle adjustment is completed
    set(HANDLES.fig.main, 'WindowButtonUpFcn', @(~, ~) updateRectangleData(editedRect, label, score));
    
    % Remove the key press and mouse up listeners to prevent unintended triggers
  
end