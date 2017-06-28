using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace RubixRacing.Cache
{
    public class CachePolicy
    {
        /// <summary>
        /// Returns a cache policy that sets the absolute expiration date to 1 day from now
        /// </summary>
        /// <returns></returns>
        public static CachePolicy OneDayAbsoluteExpirationPolicy()
        {
            return AbsoluteExpirationPolicy(1);
        }

        /// <summary>
        /// Returns a cache policy that sets the absolute expiration date to the days parameter passed in
        /// </summary>
        /// <param name="days"></param>
        /// <returns></returns>
        public static CachePolicy AbsoluteExpirationPolicy(int days)
        {
            return new CachePolicy { AbsoluteExpiration = DateTime.Now.AddDays(days) };
        }

        /// <summary>
        /// Returns a cache policy that sets the absolute expiration date to 15 minutes from now
        /// </summary>
        /// <returns></returns>
        public static CachePolicy FifteenMinuteAbsoluteExpirationPolicy()
        {
            return new CachePolicy { AbsoluteExpiration = DateTime.Now.AddMinutes(15) };
        }

        public enum CacheItemPriority
        {
            Default,
            NotRemovable
        }

        /// <summary>
        /// When set, this indicates to the cache provider that the cached item should be removed
        /// at this date and time
        /// </summary>
        public DateTimeOffset? AbsoluteExpiration { get; set; }

        /// <summary>
        /// When set, this indicates to the cache provider that the cached item should
        /// have it's expiry reset after every access. 
        /// The item should be removed if the time between the last access and current time
        /// is greater than the provided timespan
        /// </summary>
        public TimeSpan? SlidingWindowExpiration { get; set; }
    }
}
