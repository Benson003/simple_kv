const std =  @import("std");
const File = std.fs.File;

pub fn main() !void {
    var open = true;

    var in_buf: [1024]u8 = undefined;
    var out_buf: [1024]u8 = undefined;
 
    while(open){
 
    var r = File.stdin().reader(&in_buf);
    var w = File.stdout().writer(&out_buf);


    const out = &w.interface;
    const in = &r.interface;
 
        try out.print("simple_kv> ",.{});
        try out.flush();
        const input = in.takeDelimiterExclusive('\n') catch |err| {
            switch(err) {
                error.EndOfStream => {
                    open = false;
                    return;
                },
                error.StreamTooLong => {
                    try out.print("Error:Input is more than 1024 bytes!\n",.{});
                    return;
                },
                else => return err,
            }
    };

         if(std.mem.eql(u8,input,"quit")){
            open = false;
          } else {
            try out.print("{s}\n",.{input});
            try out.flush();
          }
        

        
    }
}
