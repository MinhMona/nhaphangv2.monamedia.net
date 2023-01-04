using Microsoft.AspNetCore.Mvc;

namespace NhapHangV2.API.Controllers
{
    public class HomeController : Controller
    {
        public IActionResult Index()
        {
            return View();
        }
    }
}
