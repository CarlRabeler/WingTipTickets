﻿using System.Collections.Generic;
using System.Linq;
using Newtonsoft.Json;
using System.Threading.Tasks;
using System.Web.Mvc;
using Tenant.Mvc.Core.Interfaces.Tenant;
using Tenant.Mvc.Core.Models;
using Tenant.Mvc.Models;

namespace Tenant.Mvc.Controllers
{
    public class VenueAdministrationController : BaseController
    {
        #region - Fields -

        private readonly IVenueMetaDataRepository _venueMetaDataRepository;
        private readonly IVenueRepository _venueRepository;

        #endregion

        #region - Constructors -

        public VenueAdministrationController(IVenueMetaDataRepository venueMetaDataRepository, IVenueRepository venueRepository)
        {
            // Setup Fields
            _venueMetaDataRepository = venueMetaDataRepository;
            _venueRepository = venueRepository;

            // Setup Callbacks
            _venueMetaDataRepository.StatusCallback = DisplayMessage;
            _venueRepository.StatusCallback = DisplayMessage;
        }

        #endregion

        #region - Index View -

        public ActionResult Index()
        {
            var domainModel = _venueRepository.GetVenues();

            var viewModel = new VenueIndexViewModel()
            {
                Venues = new List<VenueIndexViewModel.VenueViewModel>()
            };

            foreach (var venue in domainModel)
            {
                if (viewModel.Venues.All(v => v.VenueId != venue.VenueId))
                {
                    viewModel.Venues.Add(new VenueIndexViewModel.VenueViewModel()
                    {
                        VenueId = venue.VenueId,
                        VenueName = venue.VenueName,
                        Capacity = venue.Capacity,
                        Description = venue.Description
                    });
                }
            }

            return View(viewModel);
        }

        #endregion

        #region - Edit View -

        [HttpGet]
        public async Task<ActionResult> Edit(int id)
        {
            ViewBag.VenueId = id;
            var metaData = await _venueMetaDataRepository.GetVenueMetaData(id) ?? new VenueMetaData
            {
                VenueId = id, Data = new
                {
                }
            };

            return View(metaData);
        }

        [HttpPost]
        public async Task<ActionResult> Edit(int id, string data)
        {
            var deserializedData = JsonConvert.DeserializeObject<dynamic>(data);

            if (ModelState.IsValid)
            {
                await _venueMetaDataRepository.SetVenueMetaData(id, deserializedData);
            }

            return RedirectToAction("Index");
        }

        #endregion
    }
}