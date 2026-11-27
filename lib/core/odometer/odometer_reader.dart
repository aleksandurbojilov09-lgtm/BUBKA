/// Shared read-only contract for future maintenance; null means no reading.
abstract interface class OdometerReader {
  Future<int?> latestOdometerKm(int vehicleId);
}
