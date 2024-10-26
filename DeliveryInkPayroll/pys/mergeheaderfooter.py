import os
import sys
import re
from PyPDF2 import PdfReader, PdfWriter
from reportlab.pdfgen import canvas
from reportlab.lib.pagesizes import letter
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.pdfbase import pdfmetrics


def create_page_numbers(input_pdf):
    pageNumDict = {}
    pageNumList = []
    eidList = []
    tempCount1 = 0
    tempCount2 = 1
    tempeid = ""
    file = PdfReader(input_pdf)
    for page in file.pages:
        if "name" not in page.extract_text().lower():
            tempCount2 += 1
            pageNumDict[tempCount1] = tempCount2
            eidList.append(tempeid)
        else:
            tempCount1 += 1
            tempCount2 = 1
            pageNumDict[tempCount1] = tempCount2
            tempeid = re.search("\*\*(DEI\d+)\*\*", page.extract_text()).group(1)
            eidList.append(tempeid)

    for key in pageNumDict.keys():
        tempNum = 1
        for i in range(pageNumDict[key]):
            pageNumList.append("Page " + str(tempNum) + " of " + str(pageNumDict[key]))
            tempNum += 1

    temp_pdf = "page_numbers.pdf"
    c = canvas.Canvas(temp_pdf, pagesize=letter)

    for index, item in enumerate(pageNumList, start=0):
        pdfmetrics.registerFont(TTFont('CustomFont', 'Arial.ttf'))
        c.setFont('CustomFont', 9.5)
        c.drawString(25, 15, eidList[index])
        c.drawString(540, 15, item)  # Adjust x, y coordinates as needed
        c.showPage()  # Move to the next page

    c.save()


def merge_pdfs(header_pdf_path, page_numbers_pdf, content_pdf_path, output_pdf_path):
    header_pdf = PdfReader(header_pdf_path)
    page_number_pdf = PdfReader(page_numbers_pdf)
    header_page = header_pdf.pages[0]

    content_pdf = PdfReader(content_pdf_path)
    num_pages = len(content_pdf.pages)

    pdf_writer = PdfWriter()

    for i in range(num_pages):
        original_page = content_pdf.pages[i]

        original_page.merge_page(header_page)
        original_page.merge_page(page_number_pdf.pages[i])
        pdf_writer.add_page(original_page)

    with open(output_pdf_path, "wb") as f:
        pdf_writer.write(f)


if __name__ == "__main__":
    header_pdf_path = sys.argv[1]
    content_pdf_path = sys.argv[2]
    output_pdf_path = sys.argv[3]
    create_page_numbers(content_pdf_path)
    merge_pdfs(header_pdf_path, 'page_numbers.pdf', content_pdf_path, output_pdf_path)
    os.remove(sys.argv[1])
    os.remove(sys.argv[2])
    os.remove(sys.argv[1].replace('pdf', 'html'))
    os.remove(sys.argv[2].replace('pdf', 'html'))
    os.remove('page_numbers.pdf')
