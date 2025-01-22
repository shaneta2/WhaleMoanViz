function updateRectangleData(editedRect, label, score)
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
