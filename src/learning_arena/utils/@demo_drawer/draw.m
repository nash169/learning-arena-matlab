function draw(obj, file)
%DRAW Summary of this function goes here
%   Detailed explanation goes here

obj.demo_struct_{1} = 'position';

if obj.options_.velocity
    obj.demo_struct_{length(obj.demo_struct_)+1} = 'velocity';
end

if obj.options_.time
    obj.demo_struct_{length(obj.demo_struct_)+1} = 'time';
end

if obj.options_.labels
    obj.demo_struct_{length(obj.demo_struct_)+1} = 'labels';
end



obj.fig_handle_ = figure;
view([0 90]); axis(obj.options_.limits);
hold on; zoom off; rotate3d off; pan off; brush off; datacursormode off;

set(obj.fig_handle_,'WindowButtonDownFcn',@(h,e)button_clicked(h,e));
set(obj.fig_handle_,'WindowButtonUpFcn',[]);
set(obj.fig_handle_,'WindowButtonMotionFcn',[]);
set(obj.fig_handle_,'Pointer','circle');

obj.graphics_handle_ = gobjects(0);


% Stop button
stop_btn = uicontrol('style','pushbutton','String', 'Store Data','Callback',@stop_recording, 'position',[0 0 110 25], 'UserData', 1);

% Label button
label_btn = uicontrol('style','pushbutton','String', 'Change Label','Callback',@change_label, 'position',[150 0 210 25], 'UserData', 1);            

% Clear button
uicontrol('style','pushbutton','String', 'Clear','Callback',@clear_data, 'position',[400 0 110 25], 'UserData', 1);

% to store the data
X = [];

% flag for signaling that the demonstration has ended
demonstration_index = 0;
demonstration_index_monitor = 0;

% wait until demonstration is finished
while( (get(stop_btn, 'UserData') == 1))
    pause(0.01);
    if demonstration_index ~= demonstration_index_monitor
        x_obs{demonstration_index} = X;
        labels{demonstration_index} = label_id;
        X = [];
        demonstration_index_monitor = demonstration_index;
        set(fig,'WindowButtonDownFcn',@(h,e)button_clicked(h,e));
        set(fig,'WindowButtonUpFcn',[]);
        set(fig,'WindowButtonMotionFcn',[]);
        set(fig,'Pointer','circle');
    end
end

obj.demo_ = cell(demonstration_index_monitor,1);

% Savitzky-Golay filter and derivatives
%   x :             input data size (time, dimension)
%   dt :            sample time
%   nth_order :     max order of the derivatives 
%   n_polynomial :  Order of polynomial fit
%   window_size :   Window length for the filter

start_dem = 1 + cleared_data;

for dem = start_dem:demonstration_index_monitor
    data = [];
    
    pos = x_obs{dem}(1:2,:);
    t = x_obs{dem}(3,:);
    
    data = [data;  pos];
    
    if calc_vel
        ppx = spline(t,pos);
        ppxd = differentiate_spline(ppx);
        vel = ppval(ppxd,t);
        data = [data; vel];
    end
    
    if get_time
        data = [data; t];
    end
    
    if get_labels
        data = [data; labels{dem}*ones(1,size(t, 2))];
    end
    
    obj.demo_{dem} = data;
end

obj.demo_ = obj.demo_(start_dem:end);
end

