#import "MemoryUtils.h"
#import "ASLogger.h"

void print_free_memory() {
  mach_port_t host_port;
  mach_msg_type_number_t host_size;
  vm_size_t pagesize;
  
  host_port = mach_host_self();
  host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
  host_page_size(host_port, &pagesize);        
  
  vm_statistics_data_t vm_stat;
  
  if (host_statistics(host_port, HOST_VM_INFO, 
                      (host_info_t)&vm_stat, &host_size) != KERN_SUCCESS)
    ASLogError(@"Failed to fetch vm statistics");
  
  // Stats in bytes
  natural_t mem_used = (vm_stat.active_count +
                        vm_stat.inactive_count +
                        vm_stat.wire_count) * pagesize;
  natural_t mem_free = vm_stat.free_count * pagesize;
  natural_t mem_total = mem_used + mem_free;
  // Print stats in KB.
  ASLogWarning(@"used: %.1fKB free: %.1fKB total: %.1fKB",
        mem_used/1024.0, mem_free/1024.0, mem_total/1024.0);
}