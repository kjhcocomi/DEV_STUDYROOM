using Microsoft.AspNetCore.Mvc;
using HelloEmpty.Models;

namespace HelloEmpty.Controllers
{
    public class HomeController : Controller
    {
        public IActionResult Index()
        {
            HelloMessage msg = new HelloMessage()
            {
                Message = "Welcome to Asp.Net MVC!!!!!"
            };

            ViewBag.Noti = "Input message ans click submit";

            return View(msg);
        }
    }
}
