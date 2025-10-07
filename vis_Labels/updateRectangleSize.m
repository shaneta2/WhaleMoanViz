function updateRectangleSize(x0, y0)

% updateRectangleSize: handles live time sizing of new bounding boxes
%
% This script is called by an event listener which is set up after a
% user begins to create a new bounding box and has begun dragging the mouse. 
% The event listener triggers this script whenever the mouse moves, and
% this script updates the size of the rectangle in live time.
% Created by Michaela Alksne

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