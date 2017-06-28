using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace RubixRacing.Cache
{
    public class InMemoryCacheItem
    {
        public object Item { get; set; }
        public DateTime? ExpiryTime { get; set; }
        public string Key { get; set; }
        public CachePolicy CachePolicy { get; set; }
    }
}
