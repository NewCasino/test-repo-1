namespace Luxbook.MVC.Services
{
    using System.Collections.Generic;
    using System.Linq;
    using Extensions;
    using Models;
    using Repositories;

    public interface ISystemService
    {
        List<SystemEnum> GetSystemEnums(string type);
    }

    /// <summary>
    ///     Reads all the system tables
    /// </summary>
    public class SystemService : ISystemService
    {
        private readonly ISystemRepository _systemRepository;

        public SystemService(ISystemRepository systemRepository)
        {
            _systemRepository = systemRepository;
        }

        public List<SystemEnum> GetSystemEnums(string type)
        {
            var enums = _systemRepository.GetSystemEnums();

            return enums.Where(x => x.Type.IsSameIgnoreCase(type)).ToList();
        }
    }
}