from pathlib import Path

from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import getSampleStyleSheet
from reportlab.platypus import Paragraph, SimpleDocTemplate, Spacer


output_path = Path(__file__).parent / "documento_prueba.pdf"
styles = getSampleStyleSheet()

document = SimpleDocTemplate(
    str(output_path),
    pagesize=A4,
    title="Documento PDF de prueba",
    author="Biogest Clinic",
)
document.build(
    [
        Paragraph("Documento PDF de prueba", styles["Title"]),
        Spacer(1, 24),
        Paragraph(
            "Archivo creado para comprobar la seleccion, carga y visualizacion "
            "de documentos PDF en Biogest Clinic Mobile.",
            styles["BodyText"],
        ),
        Spacer(1, 18),
        Paragraph("Contenido de prueba: PDF valido de una pagina.", styles["BodyText"]),
    ]
)
