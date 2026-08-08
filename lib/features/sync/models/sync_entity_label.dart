/// Cómo se llama en el mostrador cada entidad del feed.
///
/// El desglose de pendientes (§11.1) es la diferencia entre "hay 14 cosas
/// esperando" y "hay 14 cobros esperando": lo primero no le dice a nadie si
/// puede seguir trabajando o si tiene que buscar señal. Y para eso los nombres
/// tienen que ser los del negocio, no los del protocolo.
String syncEntityLabel(String entity, {required int count}) => switch (entity) {
  'order' => count == 1 ? 'Pedido' : 'Pedidos',
  'order_payment' => count == 1 ? 'Cobro' : 'Cobros',
  'customer' => count == 1 ? 'Cliente' : 'Clientes',
  'expense' => count == 1 ? 'Gasto' : 'Gastos',
  'supply_sale' => count == 1 ? 'Venta de insumo' : 'Ventas de insumo',
  _ => entity,
};
