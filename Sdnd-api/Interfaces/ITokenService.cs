using Sdnd_api.Models;

namespace Sdnd_api.Interfaces;

public interface ITokenService
{
    string CreateToken(User user);
    string CreateRefreshToken();
}