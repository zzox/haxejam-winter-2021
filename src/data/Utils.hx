package data;

inline function clamp (low:Float, high:Float, val:Float):Float
    return Math.max(low, Math.min(val, high));
