import { rest } from './api';

export const verifyService = {
  // Usa la función SECURITY DEFINER que solo devuelve campos públicos
  // y solo si el folio coincide exactamente.
  getCertificateByFolio: async (folio) => {
    const { data } = await rest.get('/rpc/verify_certificate_by_folio', {
      params: { folio },
    });
    return data?.[0] || null;
  },
};
