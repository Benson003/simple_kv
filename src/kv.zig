const std = @import("std");
const autoHashMap = std.AutoHashMap;
const allocator = @import("./alloctor.zig");

pub const KvObject = struct {
    offset: usize,
    size: usize,
};

pub const KvKey = struct {
    table: [] const u8,
    key: []const u8,
};

pub const KvObjectTable = struct {
    table: autoHashMap(KvKey, KvObject),
};




