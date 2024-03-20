import axios from "axios";
import authHeader from "./auth-header";

const base = "http://localhost:7278/api";
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
  };
};

export default BaseApiService;
