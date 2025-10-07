function detectRightClick(~, ~)
    global REMORA HANDLES

    clickType = get(HANDLES.fig.main, 'SelectionType');
    if strcmp(clickType, 'alt')  % Right-click
        % Start drawing bounding box on right-click
        cursorPoint = get(HANDLES.subplt.specgram, 'CurrentPoint');
        x0 = cursorPoint(1,1);
        y0 = cursorPoint(1,2);
        
        % Create temporary rectangle to visualize the bounding box
        REMORA.tempRect = rectangle(HANDLES.subplt.specgram, 'Position', [x0, y0, 10, 10], ...
                                    'EdgeColor', 'cyan', 'LineWidth', 1.5, 'LineStyle', '--');

        % Set up drag and release functions
        set(HANDLES.fig.main, 'WindowButtonMotionFcn', @drawBoundingBox);
        set(HANDLES.fig.main, 'WindowButtonUpFcn', @finalizeAddDetectionMode);
    end
end
