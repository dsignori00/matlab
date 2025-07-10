function lla_origin = getLlaOrigin(track_label)

switch track_label
  
  case "LVMS"
    origin_lon = -115.010258;
    origin_lat = 36.2722818;
    origin_hgt = 594.6250982;
  case "TMS"
    origin_lat = 33.037;
    origin_lon = -97.283;
    origin_hgt =  192.5;
  case {"Monza", "monza"}
    % LVMS
    origin_lat = 45.618974079378670;
    origin_lon = 9.281181751068655;
    origin_hgt = 182.9000;
  otherwise
    warning("Unknown label %s. Returning default origin\n", track_label);
    origin_lat = 0;
    origin_lon = 0;
    origin_hgt = 0;
end

lla_origin = [origin_lat, origin_lon, origin_hgt];  
    
end

