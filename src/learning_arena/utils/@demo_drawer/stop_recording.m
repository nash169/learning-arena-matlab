function stop_recording(ObjectS,~)
%STOP_RECORDING Summary of this function goes here
%   Detailed explanation goes here
    set(ObjectS, 'UserData', 0);
    close;
end

