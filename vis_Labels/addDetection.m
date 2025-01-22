function addDetection(~, ~)
    global REMORA HANDLES PARAMS

    % Get the initial click position
    cursorPoint = get(HANDLES.subplt.specgram, 'CurrentPoint');
    x0 = cursorPoint(1,1);
    y0 = cursorPoint(1,2);

    % Create a temporary rectangle for visual feedback
    REMORA.tempRect = rectangle(HANDLES.subplt.specgram, 'Position', [x0, y0, 1, 1], ...
                                'EdgeColor', 'cyan', 'LineWidth', 1.5, 'LineStyle', '--');

    % Set up a mouse motion function to resize the rectangle
    set(HANDLES.fig.main, 'WindowButtonMotionFcn', @(~, ~) updateRectangleSize(x0, y0));

    % Set up a function to finalize the box when the mouse button is released
    set(HANDLES.fig.main, 'WindowButtonUpFcn', @(~, ~) finalizeBoundingBox());
end

function updateRectangleSize(x0, y0)
    global REMORA HANDLES

    % Get current cursor position
    cursorPoint = get(HANDLES.subplt.specgram, 'CurrentPoint');
    x1 = cursorPoint(1,1);
    y1 = cursorPoint(1,2);

    % Calculate new width and height
    width = x1 - x0;
    height = y1 - y0;

    % Ensure non-negative width and height
    if width < 0
        x0 = x1;
        width = abs(width);
    end
    if height < 0
        y0 = y1;
        height = abs(height);
    end

    % Update the rectangle's position
    REMORA.tempRect.Position = [x0, y0, width, height];
end
