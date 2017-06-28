namespace RubixRacing.Cache
{
    using System;
    using System.Collections.Concurrent;
    using NLog;

    public class InMemoryCacheProvider : ICacheProvider
    {
        private static readonly object CacheLock = new object();
        private readonly ILogger _logger = LogManager.GetCurrentClassLogger();

        public InMemoryCacheProvider()
        {
        }

        public InMemoryCacheProvider(ConcurrentDictionary<string, InMemoryCacheItem> cache)
        {
            Cache = cache;
        }

        private static ConcurrentDictionary<string, InMemoryCacheItem> Cache { get; set; } =
            new ConcurrentDictionary<string, InMemoryCacheItem>();

        public T GetItem<T>(Func<T> getItemFunc, CachePolicy cachePolicy, string key)
        {
            T result;

            lock (CacheLock)
            {
                if (!GetItem(key, out result))
                {
                    result = getItemFunc();
                    var cacheItem = new InMemoryCacheItem
                    {
                        Item = result,
                        CachePolicy = cachePolicy,
                        Key = key
                    };
                    TouchCacheItem(cacheItem);
                    Cache[key] = cacheItem;
                }
            }

            return result;
        }

        public bool GetItem<T>(string key, out T result)
        {
            if (Cache.ContainsKey(key))
            {
                InMemoryCacheItem cacheItem = Cache[key];
                // if item is expired then treat it as missing from cache
                if (cacheItem.ExpiryTime.HasValue && cacheItem.ExpiryTime.Value < DateTime.Now)
                {
                    _logger.Trace($"Cache EXPIRED for {key}");

                    result = default(T);
                    return false;
                }

                result = (T) cacheItem.Item;
                TouchCacheItem(cacheItem);

                _logger.Trace($"Cache HIT for {key}");

                return true;
            }

            _logger.Trace($"Cache MISS for {key}");

            result = default(T);
            return false;
        }

        public void RemoveItem(string key)
        {
            InMemoryCacheItem item;
            Cache.TryRemove(key, out item);
        }

        /// <summary>
        ///     If expirytime needs to be updated, update it according to policy
        /// </summary>
        /// <param name="cacheItem"></param>
        private void TouchCacheItem(InMemoryCacheItem cacheItem)
        {
            // if we have a sliding window then set expiry to the now + window
            if (cacheItem.CachePolicy != null && cacheItem.CachePolicy.SlidingWindowExpiration.HasValue)
                cacheItem.ExpiryTime = DateTime.Now.Add(cacheItem.CachePolicy.SlidingWindowExpiration.Value);

            // if we are looking at absolute expiration and no expiry time is set
            // if expiry time is set we don't update the absolute expiry
            if (!cacheItem.ExpiryTime.HasValue && cacheItem.CachePolicy != null &&
                cacheItem.CachePolicy.AbsoluteExpiration.HasValue)
                cacheItem.ExpiryTime = cacheItem.CachePolicy.AbsoluteExpiration.Value.DateTime;
        }
    }
}