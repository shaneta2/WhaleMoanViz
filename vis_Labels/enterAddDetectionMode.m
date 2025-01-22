
function enterAddDetectionMode()
    global HANDLES

    disp('Click and drag on the spectrogram to add a new detection.');
    
    % Set the flag to indicate we're in Add Detection mode
    isAddingDetection = true;
    
    % Set up normal click for adding a bounding box
    set(HANDLES.fig.main, 'WindowButtonDownFcn', @addDetection);
end

