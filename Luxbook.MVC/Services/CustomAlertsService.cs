using System.Collections.Generic;
using Luxbook.MVC.Models;
using Luxbook.MVC.Repositories;

namespace Luxbook.MVC.Services
{
    public interface ICustomAlertsService
    {
        List<RunnerLiability> GetLiabilities();
    }

    /// <summary>
    ///     This class is tasked to return results for custom alerts
    /// </summary>
    public class CustomAlertsService : ICustomAlertsService
    {
        private readonly IEventRepository _eventRepository;

        public CustomAlertsService(IEventRepository eventRepository)
        {
            _eventRepository = eventRepository;
        }

        public List<RunnerLiability> GetLiabilities()
        {
            return _eventRepository.GetAllEventLiabilities();
        }
    }
}