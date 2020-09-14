function ret = button_clicked(~,~)
%BUTTON_CLICKED Summary of this function goes here
%   Detailed explanation goes here
    if(strcmp(get(gcf,'SelectionType'),'normal'))
        ret = start_demonstration();
    end
end

