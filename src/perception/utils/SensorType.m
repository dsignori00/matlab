classdef SensorType
    enumeration
        LIDAR_CLUSTERING      (0)
        LIDAR_POINTPILLARS    (1)
        RADAR_CLUSTERING      (2)
        CAMERA_YOLO           (3)
        CAMERA_YOLO_ENHANCED  (4)
        VIRTUAL               (5)
    end
    
    properties
        Value uint8
    end
    
    methods
        function obj = SensorType(val)
            obj.Value = val;
        end
    end
end
