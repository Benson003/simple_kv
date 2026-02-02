const std = @import("std");
const Allocator = std.mem.Allocator;

pub const Slab = struct {
    bitmap: []u8,
    start_pos: usize,
    end_pos:usize,
    region_size:usize,
    region_count:usize,

    pub fn init(arena: []u8 ,start_index: usize, end_index: usize, region_size:usize) Slab {
        
        const region_count = (end_index - start_index)/region_size;
        const bitmap_size = (region_count + 7)/8;

        const bitmap = arena[start_index..start_index + bitmap_size];
        const start_pos = start_index + bitmap_size;

        const usable_space = end_index - start_pos;
        const usable_regions = usable_space / region_size;
        @memset(bitmap, 0);


        return Slab{
            .start_pos = start_pos,
            .end_pos = end_index,
            .region_count = usable_regions,
            .region_size = region_size,
            .bitmap = bitmap,
        };

    }

    pub fn deinit(self: *Slab,allocator: Allocator) !void {
        try allocator.free(self.bitmap);
    }

    fn isUsed(self: *Slab, index: usize)bool{
        const byte_index = index / 8;
        const bit_index = index % 8;
        return(self.bitmap[byte_index] & (1 << bit_index)) != 0;
    }
    fn setUsed(self: *Slab, index: usize)void{
        const byte_index = index / 8;
        const bit_index = index % 8;
        self.bitmap[byte_index] |= 1 << bit_index;
    }
    fn clearUsed(self: *Slab, index: usize)void{
        const byte_index = index / 8;
        const bit_index = index % 8;
        self.bitmap[byte_index] &= ~(1 << bit_index);
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



};

