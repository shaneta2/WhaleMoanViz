function updateRectangleData(editedRect, label, score)

% updateRectangleData: updates the currentEdit data for bounding boxes
% currently being edited
%
% This script is called by an event listener which is activated whenever a
% user begins to edit an existing bounding box. The use of an event
% listener is misleading, because this only runs once before shutting
% itself off (and it might as well be called when the rectngle is first
% edited). 
%
% The functionality of this script (populating the fields of currentEdit)
% is duplicated within finalizeEditMode, so this script is obsolete.

    global REMORA PARAMS HANDLES

    % Get the final position of the interactive rectangle
    pos = editedRect.Position;
    startWV = PARAMS.plot.dnum;

    % Convert the position into absolute datenums and frequency range
    startTime = startWV + pos(1) / (24 * 3600);
    endTime = startWV + (pos(1) + pos(3)) / (24 * 3600);
    minFreq = pos(2);
    maxFreq = pos(2) + pos(4);

    % Update currentEdit with the finalized values (directly store in REMORA)
    REMORA.lt.lVis_det.currentEdit.start_datenum = startTime;
    REMORA.lt.lVis_det.currentEdit.end_datenum = endTime;
    REMORA.lt.lVis_det.currentEdit.min_freq = minFreq;
    REMORA.lt.lVis_det.currentEdit.max_freq = maxFreq;
    REMORA.lt.lVis_det.currentEdit.label = label;
    REMORA.lt.lVis_det.currentEdit.score = score;

    set(HANDLES.fig.main, 'WindowButtonUpFcn', '');

end
