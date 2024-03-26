import axios from "axios";
const API_URL = "http://localhost:7278/api/Account/";

class AuthService {
  login(user) {
    console.log(user, "from auth-service");
    return axios
      .post(API_URL + "login", {
        username: user.username,
        password: user.password,
      })
      .then((response) => {
        if (response.data.token) {
          console.log("response of the login :", response.data);
          localStorage.setItem("user", JSON.stringify(response.data));
        }

        return response.data;
      });
  }

  logout() {
    console.log("out");
    localStorage.removeItem("user");
  }

  register(user) {
    return axios.post(API_URL + "register", {
      username: user.username,
      email: user.email,
      password: user.password,
    });
  }
}

export default new AuthService();
