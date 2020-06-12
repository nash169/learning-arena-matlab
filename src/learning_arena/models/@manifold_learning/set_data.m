function set_data(obj, data)
    % Set data. This is the list of all points inside the training
    % dataset
    obj.data_ = data;
    [obj.m_, obj.d_] = size(data);

    obj.is_data_ = true;
    obj.is_colors_ = false;
    obj.reset;
end
