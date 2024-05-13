import axios from "axios";
import authHeader from "./auth-header";
import { toast } from "vue3-toastify";
import { useRouter } from "vue-router";

const router = useRouter();
const base = "https://localhost:7278/api";
const axiosInstance = axios.create({
  baseURL: base,
});

function addAuthHeaders(config) {
  const headers = authHeader();

  if (headers) {
    return { ...config, headers };
  }

  return config;
}

axiosInstance.interceptors.request.use(addAuthHeaders);
axiosInstance.interceptors.response.use(
  (response) => response,
  (error) => {
    console.log(error.response.status);
    if (error.response.status == 401) {
      //console.error("You are not authenticated to access this resource");
      // remove the token from local storage
      localStorage.removeItem("user");
      toast.error("You are not authenticated, please login to continue.");
      // redirect to login page
      router.push("/signin");
    }
    if (error.response.status === 400) {
      toast.error("Bad request, please check your request and try again.", {
        position: "top-right",
        zIndex: 50000,
      });
    }
    if (error.response.status === 403) {
      toast.error("You are not authorized to access this resource", {
        position: "top-right",
        zIndex: 50000,
      });
    }
    if (error.response.status === 500) {
      toast.error("Internal server error", {
        position: "top-right",
        zIndex: 50000,
      });
    }
    if (error.response.status === 404) {
      toast.error("Resource not found", {
        position: "top-right",
        style: {
          zIndex: 50000,
        },
      });
    }
    return Promise.reject(error);
  }
);
const BaseApiService = (resource) => {
  return {
    list: (config = {}) => axiosInstance.get(`${resource}`, config),
    get: (id, config = {}) => axiosInstance.get(`${resource}/${id}`, config),
    create: (payload, config = {}) =>
      axiosInstance.post(`${resource}`, payload, config),
    update: (id, payload, config = {}) =>
      axiosInstance.put(`${resource}/${id}`, payload, config),
    patch: (id, payload, config = {}) =>
      axiosInstance.patch(`${resource}/${id}`, payload, config),
    remove: (id, config = {}) =>
      axiosInstance.delete(`${resource}/${id}`, config),
    removeObj: (payload, config = {}) =>
      axiosInstance.delete(`${resource}`, { data: payload }, config),
  };
};

export default BaseApiService;
