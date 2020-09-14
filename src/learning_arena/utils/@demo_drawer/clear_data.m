function clear_data(ObjectS, ~)
%CLEAR_DATA Summary of this function goes here
%   Detailed explanation goes here
    data = [];
    X = [];
    label_id = 1;
    cleared_data = demonstration_index;
    set(ObjectS, 'UserData', 0); % unclick button
    delete(hp);
end

