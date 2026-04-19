import SwiftUI
import Charts

struct DashboardView: View {
    @EnvironmentObject private var patientVM: PatientViewModel

    var body: some View {
        List {
            Section("Filtros") {
                TextField("Filtrar por quarto", text: $patientVM.selectedQuarto)
                Picker("Setor", selection: $patientVM.selectedSetor) {
                    Text("Todos").tag(PatientSector?.none)
                    ForEach(PatientSector.allCases) { Text($0.rawValue).tag(PatientSector?.some($0)) }
                }
                Picker("Medicação", selection: $patientVM.selectedMedication) {
                    Text("Todas").tag(Medication?.none)
                    ForEach(Medication.allCases) { Text($0.displayName).tag(Medication?.some($0)) }
                }
            }

            Section("Pacientes por dia") {
                Chart(chartData, id: \.day) { item in
                    BarMark(
                        x: .value("Dia", item.day, unit: .day),
                        y: .value("Qtd", item.count)
                    )
                    .foregroundStyle(.blue)
                }
                .frame(height: 220)
            }

            Section("Histórico completo") {
                ForEach(patientVM.history) { event in
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(event.fieldName): \(event.oldValue) → \(event.newValue)")
                            .font(.subheadline)
                        Text("Por: \(event.changedByName) • \(event.changedAt.formatted(date: .numeric, time: .shortened))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle("Gerencial")
    }

    private var chartData: [(day: Date, count: Int)] {
        let grouped = Dictionary(grouping: patientVM.filteredPatients) {
            Calendar.current.startOfDay(for: $0.createdAt)
        }
        return grouped.map { (day: $0.key, count: $0.value.count) }.sorted { $0.day < $1.day }
    }
}
