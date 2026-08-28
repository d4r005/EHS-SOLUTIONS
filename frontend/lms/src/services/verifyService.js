import { rest } from './api';

export const verifyService = {
  getCertificateByFolio: async (folio) => {
    const { data } = await rest.get(
      `/certificates?certificate_number=eq.${folio}&select=*,student:users(first_name,last_name),course:courses(title,duration_hours)`
    );
    return data?.[0] || null;
  },
};
