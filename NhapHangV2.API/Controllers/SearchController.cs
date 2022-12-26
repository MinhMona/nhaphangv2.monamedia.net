using Microsoft.AspNetCore.Mvc;
using NhapHangV2.Interface.Services;
using NhapHangV2.Request;
using NhapHangV2.Utilities;
using System.ComponentModel;
using System.Net;

namespace NhapHangV2.API.Controllers
{
    [Route("api/search")]
    [ApiController]
    [Description("Tìm kiếm sản phẩm")]
    public class SearchController : ControllerBase
    {
        private readonly ISearchService searchService;
        public SearchController(ISearchService searchService)
        {
            this.searchService = searchService;
        }

        [HttpPost]
        public AppDomainResult SearchContent(SearchRequest searchRequest)
        {
            return searchService.SearchContent(searchRequest.Site, searchRequest.Content);
        }
    }
}
