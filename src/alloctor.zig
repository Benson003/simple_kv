const std = @import("std");
const Allocator = std.mem.Allocator;

pub const Slab = struct {
    bitmap: []bool,
    start_pos: usize,
    end_pos:usize,
    region_size:usize,
    region_count:usize,

    pub fn init(allocator:Allocator,start_index: usize, end_index: usize, region_size:usize) Slab {
        
        const region_count = (end_index - start_index)/region_size;
        const bitmap = try allocator.alloc(bool, region_count);
        @memset(bitmap, false);


        return Slab{
            .allocator = allocator,
            .start_pos = start_index,
            .end_pos = end_index,
            .region_count = region_count,
            .region_size = region_size,
            .bitmap = bitmap,
        };

    }

    pub fn deinit(self: *Slab,allocator: Allocator) !void {
        try allocator.free(self.bitmap);
    }

    pub fn alloc(self: *Slab, size: usize) !usize {
        const regions_needed = (size + self.region_size - 1)/self.region_size;
        var count: usize = 0;
        var start_idx: usize = 0;

        // Sliding window to find contigous region
        for(self.bitmap,0..)|used, idx|{
            if(!used){
                if(count == 0) start_idx = idx;
                count += 1;
                if(count == regions_needed){
                    // Mark the regions found as used
                    @memset(self.bitmap[start_idx..start_idx+regions_needed],true);

                    // Return the start index
                    return start_idx;
                } else {
                    count = 0;
                }

            }
        }
        return error.OutOfMemory;
    }

    pub fn free(self: *Slab, index: usize, size:usize)void{
        const start_idx = (index - self.start_pos)/self.region_size;
        const regions_to_free = (size + self.region_size - 1 )/self.region_size;
        for(start_idx..start_idx + regions_to_free)|i|{
            self.bitmap[i] = false;
        }
    }

    pub fn isEmpty(self: *Slab) bool {
    for (self.bitmap) |used| {
        if (used) return false;
    }
    return true;
    }


};

