function drawBoundingBox(~, ~)
    global REMORA HANDLES

    cursorPoint = get(HANDLES.subplt.specgram, 'CurrentPoint');
    x1 = cursorPoint(1,1);
    y1 = cursorPoint(1,2);

    % Get initial position of the rectangle
    pos = REMORA.tempRect.Position;
    x0 = pos(1);
    y0 = pos(2);

    % Calculate width and height, ensuring they are non-negative
    width = abs(x1 - x0);
    height = abs(y1 - y0);

    % Adjust starting position if necessary
    if x1 < x0
        x0 = x1;
    end
    if y1 < y0
        y0 = y1;
    end

    % Update the temporary rectangle with non-negative width and height
    REMORA.tempRect.Position = [x0, y0, width, height];
end
