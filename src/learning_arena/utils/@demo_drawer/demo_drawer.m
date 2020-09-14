classdef demo_drawer < handle
    %DEMO_DRAWER Summary of this class goes here
    %   Detailed explanation goes here

    %=== PUBLIC ===%
    properties
        file_
        options_list_ = {'limits', 'velocity', 'time', 'labels'}
    end

    methods

        function obj = demo_drawer(varargin)
            %DEMO_DRAWER Construct an instance of this class
            %   Detailed explanation goes here
            obj.init;

            if nargin > 0; obj.set_options(varargin{:}); end
        end

        set_options(obj, varargin);

        save(obj, file);

        draw(obj, file);
    end

    %=== PROTECTED ===%
    properties (Access = protected)
        options_;

        data;
        demo_index_;

        demo_;
        demo_struct_;

        fig_handle_;
        graphics_handle_;
    end

    methods (Access = protected)
        init(obj);
    end

    methods (Access = protected, Static = true)
        clear_data(ObjectS, ~);

        stop_recording(ObjectS, ~);

        change_label(ObjectS, ~);

        ret = button_clicked(~, ~);
    end

end
