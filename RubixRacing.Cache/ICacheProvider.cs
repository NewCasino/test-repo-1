namespace RubixRacing.Cache
{
    using System;

    public interface ICacheProvider
    {
        /// <summary>
        ///     Attempts to retrieve a key from the cache, if key does not exist the getItemFunc will be executed
        ///     and the value stored in cache according to the cache policy
        /// </summary>
        /// <typeparam name="T"></typeparam>
        /// <param name="getItemFunc">function to be executed to retrieve the value if not found in cache</param>
        /// <param name="cachePolicy">
        ///     The redis cache provider doesn't support sliding windows. A key will expire at the end of the
        ///     timespan.
        /// </param>
        /// <param name="key"></param>
        /// <returns></returns>
        T GetItem<T>(Func<T> getItemFunc, CachePolicy cachePolicy, string key);

        /// <summary>
        ///     Attempts to retrieve a key from the cache, the boolean return value indicates if the item is in cache or not
        /// </summary>
        /// <typeparam name="T"></typeparam>
        /// <param name="key"></param>
        /// <param name="result">The cache result if the key is found</param>
        /// <returns></returns>
        bool GetItem<T>(string key, out T result);

        /// <summary>
        ///     Removes a given key item from the cache
        /// </summary>
        /// <param name="key"></param>
        void RemoveItem(string key);
    }
}