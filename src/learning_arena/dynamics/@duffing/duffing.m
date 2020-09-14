classdef duffing < abstract_dynamics
    %LINEAR_SYSTEM Summary of this class goes here
    %   Detailed explanation goes here

    %=== PUBLIC ===%
    methods

        function obj = duffing(varargin)
            %LINEAR_SYSTEM Construct an instance of this class
            %   Detailed explanation goes here
            obj = obj@abstract_dynamics(varargin{:});
        end

    end

    %=== PROTECTED ===%
    methods (Access = protected)
        signature(obj)

        f = calc_field(obj, x)
    end

end
