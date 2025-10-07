% rightClickMenu: contains functions to set up and assign (right click) context menus
%
% This script contains all the functions required for creating context
% menus on right clicks. 

function wmvClickMenu(action)
global REMORA

    if strcmp(action, 'Initialize')
    % creates the context menu template for each detection type 
    % and stores it in REMORA global variable
    
        % initialize struct to hold click menus
        clickMenus = struct('TP', [], 'FP', [], 'FN', []);
    
        clickMenus.TP = uicontextmenu;
        uimenu(tpMenu, 'Label', 'Edit Label', 'Callback', @(src, evt) editLabelCallback(src));
        uimenu(tpMenu, 'Label', 'Delete Box', 'Callback', @(src, evt) deleteBoxCallback(src));
    
        fpMenu = uicontextmenu;
        fnMenu = uicontextmenu;
        
    
    end
    
    if strcmp(action, 'GetMenu')
    % getClickMenu: given some detection, returns the menu appropriate for it's type.
    %
    % inputs: 
    % - absIdx: the index of the detection
    % outputs:
    % - menu (UIContextMenu): the corresponding right click menu
    end
    
    % changeLabel: a callback function to handle changing a detection's label
    %
    % This function is called by the right click menu (UIContextMenu) whenever
    % a change of labels is clicked.
    %
    % inputs:
    % - absIdx: the index of the detection


end